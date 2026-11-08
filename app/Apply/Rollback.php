<?php

namespace App\Apply;

use App\Analysis\Reference;
use App\Analysis\References;
use Illuminate\Database\ConnectionInterface;

final readonly class Rollback
{
    public function __construct(
        private ConnectionInterface $db,
        private CacheClearer $cache,
        private string $home,
    ) {}

    public function run(Journal $journal, ?string $backupPath): void
    {
        if ($journal->rolledBackAt !== null) {
            throw new RollbackConflict(["journal {$journal->id} was already rolled back at {$journal->rolledBackAt}"]);
        }

        BackupCheck::assertFresh($backupPath);

        $this->db->transaction(function () use ($journal): void {
            $conflicts = [...$this->changedRows($journal), ...$this->usedCopies($journal)];
            if ($conflicts !== []) {
                throw new RollbackConflict($conflicts);
            }

            foreach (array_reverse($journal->changes) as $change) {
                $this->db->table($change['table'])
                    ->where($change['key'])
                    ->where($change['column'], $change['new'])
                    ->update([$change['column'] => $change['old']]);
            }

            foreach (array_reverse($journal->created) as $row) {
                $this->db->table($row['table'])->where('id', $row['id'])->delete();
            }

            $journal->rolledBackAt = gmdate('c');
            $journal->save($this->home);
        });

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
}
