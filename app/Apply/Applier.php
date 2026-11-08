<?php

namespace App\Apply;

use App\Analysis\CopyRef;
use App\Analysis\MovePlan;
use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\RowChange;
use App\Analysis\RowCopy;
use Illuminate\Database\ConnectionInterface;
use Illuminate\Support\Str;
use RuntimeException;

final readonly class Applier
{
    private const string LOCK_TIMEOUT = '5s';

    public function __construct(
        private ConnectionInterface $db,
        private Planner $planner,
        private CacheClearer $cache,
        private string $home,
    ) {}

    public function apply(MoveRequest $request, string $confirmedFingerprint, ?string $backupPath): Journal
    {
        BackupCheck::assertFresh($backupPath);

        $journal = $this->db->transaction(function () use ($request, $confirmedFingerprint, $backupPath): Journal {
            $this->db->statement("set local lock_timeout = '".self::LOCK_TIMEOUT."'");

            $plan = $this->planner->plan($request);
            $this->assertApplicable($plan, $confirmedFingerprint);

            $created = $this->insertCopies($plan->copies);
            $changes = $this->applyChanges($plan->changes, $created);

            $journal = new Journal(
                id: Journal::newId(),
                createdAt: gmdate('c'),
                request: $request->toArray(),
                changes: $changes,
                created: array_values($created),
                backupPath: (string) $backupPath,
            );
            $journal->save($this->home);

            return $journal;
        });

        $this->cache->clear();

        return $journal;
    }

    private function assertApplicable(MovePlan $plan, string $confirmedFingerprint): void
    {
        if ($plan->hasBlockers()) {
            throw new RuntimeException('The plan has blockers. Run plan to see them.');
        }

        if (! hash_equals($confirmedFingerprint, $plan->fingerprint())) {
            throw new RuntimeException('The Coolify database changed since the plan was shown. Nothing was written. Run coolhop again.');
        }
    }

    /**
     * @param  list<RowCopy>  $copies
     * @return array<string, array{table: string, id: int, ref: string}>
     */
    private function insertCopies(array $copies): array
    {
        $created = [];

        foreach ($copies as $copy) {
            $row = (array) ($this->db->table($copy->table)->find($copy->sourceId)
                ?? throw new RuntimeException("{$copy->table} {$copy->sourceId} disappeared."));
            unset($row['id']);

            $values = [...$row, ...$copy->overrides];
            if (array_key_exists('uuid', $values)) {
                $values['uuid'] = Str::lower(Str::random(24));
            }
            foreach (['created_at', 'updated_at'] as $timestamp) {
                if (array_key_exists($timestamp, $values)) {
                    $values[$timestamp] = now();
                }
            }

            $id = (int) $this->db->table($copy->table)->insertGetId($values);
            $created[$copy->ref] = ['table' => $copy->table, 'id' => $id, 'ref' => $copy->ref];
        }

        return $created;
    }

    /**
     * @param  list<RowChange>  $changes
     * @param  array<string, array{table: string, id: int, ref: string}>  $created
     * @return list<array{table: string, key: array<string, int|string|null>, column: string, old: int|string|null, new: int|string|null}>
     */
    private function applyChanges(array $changes, array $created): array
    {
        $applied = [];

        foreach ($changes as $change) {
            $new = $change->new instanceof CopyRef ? $created[$change->new->ref]['id'] : $change->new;

            $affected = $this->db->table($change->table)
                ->where($change->key)
                ->where(fn ($q) => $change->old === null ? $q->whereNull($change->column) : $q->where($change->column, $change->old))
                ->update([$change->column => $new]);

            if ($affected !== 1) {
                throw new RuntimeException("Expected to update one row of {$change->table} ".json_encode($change->key).", updated {$affected}.");
            }

            $key = array_key_exists($change->column, $change->key) ? [...$change->key, $change->column => $new] : $change->key;
            $applied[] = ['table' => $change->table, 'key' => $key, 'column' => $change->column, 'old' => $change->old, 'new' => $new];
        }

        return $applied;
    }
}
