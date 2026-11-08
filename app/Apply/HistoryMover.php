<?php

declare(strict_types=1);

namespace App\Apply;

use App\Analysis\AuditTrail;
use Illuminate\Database\ConnectionInterface;
use RuntimeException;

final readonly class HistoryMover
{
    public const string KIND = 'history';

    public function __construct(
        private ConnectionInterface $db,
        private string $home,
    ) {}

    /**
     * @return list<int>
     */
    public function pending(Journal $move): array
    {
        if ($move->rolledBackAt !== null) {
            throw new RuntimeException("Journal {$move->id} was rolled back, so its history stays where it is.");
        }

        $moved = [];
        foreach ($move->changes as $change) {
            if ($change['column'] === 'team_id' && isset($change['key']['id'])) {
                $moved[$change['table']][] = (int) $change['key']['id'];
            }
        }

        return new AuditTrail($this->db)->eventIds((int) $move->request['from'], $moved);
    }

    public function move(Journal $move, ?string $backupPath): ?Journal
    {
        BackupCheck::assertFresh($backupPath);

        return $this->db->transaction(function () use ($move, $backupPath): ?Journal {
            $this->db->statement("set local lock_timeout = '5s'");

            $ids = $this->pending($move);
            if ($ids === []) {
                return null;
            }

            $from = (int) $move->request['from'];
            $to = (int) $move->request['to'];
            $affected = $this->db->table('audit_events')->whereIn('id', $ids)->where('team_id', $from)->update(['team_id' => $to]);
            if ($affected !== count($ids)) {
                throw new RuntimeException('Audit events changed while moving them. Nothing was written.');
            }

            $journal = new Journal(
                id: Journal::newId(),
                createdAt: gmdate('c'),
                request: [...$move->request, 'kind' => self::KIND, 'history_of' => $move->id],
                changes: array_map(fn (int $id): array => ['table' => 'audit_events', 'key' => ['id' => $id], 'column' => 'team_id', 'old' => $from, 'new' => $to], $ids),
                created: [],
                backupPath: (string) $backupPath,
            );
            $journal->save($this->home);

            return $journal;
        });
    }
}
