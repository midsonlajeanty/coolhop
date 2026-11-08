<?php

namespace App\Apply;

use App\Analysis\IssueLevel;
use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\Reference;
use App\Analysis\References;
use App\Instance\HostedResource;
use App\Instance\Inventory;
use App\Security\Decryptor;
use Illuminate\Database\ConnectionInterface;
use RuntimeException;
use Throwable;

final readonly class Rollback
{
    private const array ANCHORED_TABLES = [
        'projects',
        'scheduled_database_backups',
        'scheduled_volume_backups',
        'scheduled_tasks',
        'shared_environment_variables',
    ];

    private const array SPLIT_BLOCKERS = ['mixed_project', 'split_destinations', 'unknown_destination'];

    public function __construct(
        private ConnectionInterface $db,
        private CacheClearer $cache,
        private string $home,
        private Planner $planner,
        private Decryptor $decryptor,
    ) {}

    public function run(Journal $journal, ?string $backupPath): void
    {
        if ($journal->rolledBackAt !== null) {
            throw new RollbackConflict(["journal {$journal->id} was already rolled back at {$journal->rolledBackAt}"]);
        }

        BackupCheck::assertFresh($backupPath);

        try {
            $this->db->transaction(function () use ($journal): void {
                $this->db->statement("set local lock_timeout = '5s'");

                $conflicts = [...$this->changedRows($journal), ...$this->usedCopies($journal)];
                if ($conflicts === [] && ($journal->request['kind'] ?? null) !== HistoryMover::KIND) {
                    $conflicts = [...$this->drift($journal), ...$this->usedTeamVariables($journal)];
                }
                if ($conflicts !== []) {
                    throw new RollbackConflict($conflicts);
                }

                foreach (array_reverse($journal->changes) as $change) {
                    $affected = $this->db->table($change['table'])
                        ->where($change['key'])
                        ->where($change['column'], $change['new'])
                        ->update([$change['column'] => $change['old']]);

                    if ($affected !== 1) {
                        throw new RuntimeException("Expected to revert one row of {$change['table']} ".json_encode($change['key']).", reverted {$affected}.");
                    }
                }

                foreach (array_reverse($journal->created) as $row) {
                    $this->db->table($row['table'])->where('id', $row['id'])->delete();
                }

                $journal->rolledBackAt = gmdate('c');
                $journal->save($this->home);
            });
        } catch (Throwable $e) {
            if ($journal->rolledBackAt !== null) {
                $journal->rolledBackAt = null;
                $journal->save($this->home);
            }

            throw $e;
        }

        $this->cache->clear();
    }

    /**
     * @return list<string>
     */
    private function changedRows(Journal $journal): array
    {
        $conflicts = [];

        foreach ($journal->changes as $change) {
            $current = $this->db->table($change['table'])->where($change['key'])->value($change['column']);
            if ($current === null || (string) $current !== (string) $change['new']) {
                $conflicts[] = sprintf('%s %s: %s is %s, coolhop set %s', $change['table'], json_encode($change['key']), $change['column'], var_export($current, true), $change['new']);
            }
        }

        return $conflicts;
    }

    /**
     * @return list<string>
     */
    private function usedCopies(Journal $journal): array
    {
        $conflicts = [];

        foreach ($journal->created as $row) {
            $expected = collect($journal->changes)->filter(fn ($c): bool => (string) $c['new'] === (string) $row['id'] && $this->points($c, $row['table']))->count();
            $actual = collect(References::to($row['table']))
                ->sum(fn (Reference $reference): int => $reference->query($this->db, $row['id'])->count());

            if ($actual > $expected) {
                $conflicts[] = "{$row['table']} {$row['id']} (copied by coolhop) is now used by rows created after the move";
            }
        }

        return $conflicts;
    }

    /**
     * @param  array{table: string, column: string}  $change
     */
    private function points(array $change, string $table): bool
    {
        return collect(References::to($table))->contains(fn (Reference $r): bool => $r->table === $change['table'] && $r->column === $change['column']);
    }

    /**
     * @return list<string>
     */
    private function drift(Journal $journal): array
    {
        $request = $journal->request;
        $inverse = $this->planner->plan(new MoveRequest((int) $request['to'], (int) $request['from'], array_values(array_map(intval(...), (array) $request['servers']))));

        $known = [];
        foreach ($journal->changes as $change) {
            $known["{$change['table']}:".json_encode($change['key'])] = true;
        }

        $conflicts = [];
        foreach ($inverse->changes as $change) {
            if ($change->column === 'team_id' && in_array($change->table, self::ANCHORED_TABLES, true) && ! isset($known["{$change->table}:".json_encode($change->key)])) {
                $conflicts[] = "{$change->table} {$change->key['id']} was added to the moved servers after the move";
            }
        }

        foreach ($inverse->issuesAt(IssueLevel::Blocker) as $issue) {
            if (in_array($issue->code, self::SPLIT_BLOCKERS, true)) {
                $conflicts[] = $issue->message;
            }
        }

        return $conflicts;
    }

    /**
     * @return list<string>
     */
    private function usedTeamVariables(Journal $journal): array
    {
        $copied = collect($journal->created)->where('table', 'shared_environment_variables')->pluck('id');
        $keys = $this->db->table('shared_environment_variables')->whereIn('id', $copied)->where('type', 'team')->pluck('key')->all();
        if ($keys === [] || ! $this->decryptor->canDecrypt()) {
            return [];
        }

        $movedProjects = collect($journal->changes)->where('table', 'projects')->map(fn (array $c): int => (int) $c['key']['id'])->all();
        $others = array_filter(
            new Inventory($this->db)->resourcesOfTeam((int) $journal->request['to']),
            fn (HostedResource $r): bool => ! in_array($r->projectId, $movedProjects, true),
        );

        $conflicts = [];
        foreach (collect($others)->groupBy(fn (HostedResource $r): string => $r->morphClass()) as $morph => $resources) {
            $payloads = $this->db->table('environment_variables')
                ->where('resourceable_type', $morph)
                ->whereIn('resourceable_id', $resources->pluck('id'))
                ->whereNotNull('value')
                ->pluck('value');

            foreach ($payloads as $payload) {
                $value = $this->decryptor->decrypt((string) $payload) ?? '';
                foreach ($keys as $key) {
                    if (preg_match('/\{\{\s*team\.'.preg_quote((string) $key, '/').'\s*\}\}/', $value) === 1) {
                        $conflicts[] = "team variable {$key} (copied by coolhop) is now used by other resources of the target team";
                    }
                }
            }
        }

        return array_values(array_unique($conflicts));
    }
}
