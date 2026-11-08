<?php

declare(strict_types=1);

namespace App\Commands;

use App\Apply\HistoryMover;
use App\Apply\Journal;
use LaravelZero\Framework\Commands\Command;
use RuntimeException;

class HistoryCommand extends Command
{
    protected $signature = 'history {journal : Journal id printed by apply} {--yes : Confirm without asking}';

    protected $description = 'Move the audit history left behind by an earlier move';

    public function handle(HistoryMover $mover): int
    {
        try {
            $move = Journal::fromFile(Journal::path((string) config('coolhop.home'), (string) $this->argument('journal')));
            $pending = count($mover->pending($move));
        } catch (RuntimeException $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        if ($pending === 0) {
            $this->info('No audit events of the moved servers are left in the source team.');

            return self::SUCCESS;
        }

        if (! $this->option('yes') && ! $this->input->isInteractive()) {
            $this->error('Pass --yes to confirm when there is no terminal.');

            return PlanCommand::INVALID;
        }

        if (! $this->option('yes') && ! $this->confirm("Move {$pending} audit events to the target team?")) {
            return PlanCommand::INVALID;
        }

        try {
            $journal = $mover->move($move, getenv('COOLHOP_BACKUP') ?: null);
        } catch (RuntimeException $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        if (! $journal instanceof Journal) {
            $this->info('No audit events of the moved servers are left in the source team.');

            return self::SUCCESS;
        }

        $this->info(sprintf('Moved %d audit events.', count($journal->changes)));
        $this->line('Journal: '.$journal->id);
        $this->line('Undo with: curl -fsSL '.config('coolhop.install_url').' | bash -s -- rollback '.$journal->id);

        return self::SUCCESS;
    }
}
