<?php

namespace App\Analysis\Rules;

use App\Analysis\IssueLevel;
use App\Analysis\PlanBuilder;
use App\Analysis\Reference;
use App\Analysis\References;
use App\Instance\HostedResource;
use Illuminate\Support\Collection;

final class SharedItemRule implements Rule
{
    /** @var array<string, array<int, true>> */
    private array $moving = [];

    public function apply(PlanBuilder $plan): void
    {
        $this->moving = [
            'servers' => array_fill_keys($plan->serverIds(), true),
            'projects' => $this->projectIds($plan),
            'applications' => $this->idsOf($plan->movingResources('applications')),
        ];

        $this->moveScheduledRows($plan);

        foreach (array_keys(References::shared()) as $itemTable) {
            $this->resolve($plan, $itemTable);
        }
    }

    private function moveScheduledRows(PlanBuilder $plan): void
    {
        $byMorph = collect($plan->movingResources())->groupBy(fn (HostedResource $r): string => $r->morphClass());

        $databaseBackups = $this->rowsMatchingMorph($plan, 'scheduled_database_backups', 'database_type', 'database_id', $byMorph);
        $volumeBackups = $this->rowsMatchingMorph($plan, 'scheduled_volume_backups', 'backupable_type', 'backupable_id', $byMorph);
        $tasks = $plan->db->table('scheduled_tasks')
            ->where('team_id', $plan->from->id)
            ->where(fn ($q) => $q
                ->whereIn('application_id', array_keys($this->moving['applications']))
                ->orWhereIn('service_id', array_keys($this->idsOf($plan->movingResources('services')))))
            ->pluck('id')->map(fn ($id): int => (int) $id)->values()->all();

        foreach (['scheduled_database_backups' => $databaseBackups, 'scheduled_volume_backups' => $volumeBackups, 'scheduled_tasks' => $tasks] as $table => $ids) {
            $this->moving[$table] = array_fill_keys($ids, true);
            foreach ($ids as $id) {
                $plan->moveToTarget($table, $id);
            }
        }

        $this->moving['scheduled_database_backup_s3_storage'] = $this->pivotIds($plan, 'scheduled_database_backup_s3_storage', 'scheduled_database_backup_id', $databaseBackups);
        $this->moving['scheduled_volume_backup_s3_storage'] = $this->pivotIds($plan, 'scheduled_volume_backup_s3_storage', 'scheduled_volume_backup_id', $volumeBackups);
    }

    private function resolve(PlanBuilder $plan, string $itemTable): void
    {
        $references = $this->referencesTo($plan, $itemTable);
        $taken = $this->takenIds($plan, $itemTable);
        $itemIds = $references->filter(fn ($ref): bool => $ref['moving'])->pluck('item')->merge($taken)->unique();

        $items = $plan->db->table($itemTable)->whereIn('id', $itemIds)->get()->keyBy('id');
        $this->moving[$itemTable] = [];

        foreach ($items as $id => $item) {
            if ((int) $item->team_id !== $plan->from->id || ($item->is_system_wide ?? false)) {
                continue;
            }

            $refs = $references->where('item', (int) $id);
            $staying = $refs->reject(fn ($ref): bool => $ref['moving']);

            if ($staying->isEmpty()) {
                $plan->moveToTarget($itemTable, (int) $id);
                $this->moving[$itemTable][(int) $id] = true;

                continue;
            }

            if (! in_array($itemTable, References::COPYABLE, true)) {
                $plan->issue(IssueLevel::Blocker, 'shared_git_app', sprintf(
                    '%s "%s" is used by moving applications and by applications that stay. Coolify cannot hold the same app in two teams.',
                    $itemTable, $item->name,
                ));

                continue;
            }

            $copy = $plan->copy($itemTable, (int) $id);
            foreach ($refs->filter(fn ($ref): bool => $ref['moving']) as $ref) {
                $plan->change($ref['table'], ['id' => $ref['id']], $ref['column'], (int) $id, $copy);
            }
        }
    }

    /**
     * @return Collection<int, array{item: int, table: string, column: string, id: int, moving: bool}>
     */
    private function referencesTo(PlanBuilder $plan, string $itemTable): Collection
    {
        $ownedIds = $plan->db->table($itemTable)->where('team_id', $plan->from->id)->pluck('id');

        return collect(References::to($itemTable))->flatMap(function (Reference $reference) use ($plan, $ownedIds) {
            $table = $reference->table;
            $column = $reference->column;

            return $reference->query($plan->db, $ownedIds)
                ->get(['id', $column])
                ->map(fn ($row): array => [
                    'item' => (int) $row->{$column},
                    'table' => $table,
                    'column' => $column,
                    'id' => (int) $row->id,
                    'moving' => isset($this->moving[$table][(int) $row->id]),
                ]);
        })->values();
    }

    /**
     * @return list<int>
     */
    private function takenIds(PlanBuilder $plan, string $itemTable): array
    {
        $ids = [];
        foreach ($plan->request->takeUnused as $item) {
            [$table, $id] = explode(':', $item, 2) + [1 => '0'];
            if ($table === $itemTable) {
                $ids[] = (int) $id;
            }
        }

        return $ids;
    }

    /**
     * @param  Collection<string, Collection<int, HostedResource>>  $byMorph
     * @return list<int>
     */
    private function rowsMatchingMorph(PlanBuilder $plan, string $table, string $typeColumn, string $idColumn, Collection $byMorph): array
    {
        if ($byMorph->isEmpty()) {
            return [];
        }

        return array_values($plan->db->table($table)
            ->where('team_id', $plan->from->id)
            ->where(function ($q) use ($byMorph, $typeColumn, $idColumn): void {
                foreach ($byMorph as $morph => $resources) {
                    $q->orWhere(fn ($q) => $q->where($typeColumn, $morph)->whereIn($idColumn, $resources->pluck('id')));
                }
            })
            ->pluck('id')->map(fn ($id): int => (int) $id)->all());
    }

    /**
     * @param  list<int>  $parentIds
     * @return array<int, true>
     */
    private function pivotIds(PlanBuilder $plan, string $table, string $column, array $parentIds): array
    {
        return array_fill_keys($plan->db->table($table)->whereIn($column, $parentIds)->pluck('id')->map(fn ($id): int => (int) $id)->all(), true);
    }

    /**
     * @return array<int, true>
     */
    private function projectIds(PlanBuilder $plan): array
    {
        return array_fill_keys(
            collect($plan->movingResources())->pluck('projectId')->unique()->values()->all(),
            true,
        );
    }

    /**
     * @param  list<HostedResource>  $resources
     * @return array<int, true>
     */
    private function idsOf(array $resources): array
    {
        return array_fill_keys(array_map(fn (HostedResource $r): int => $r->id, $resources), true);
    }
}
