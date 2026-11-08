<?php

namespace App\Commands;

use App\Apply\Journal;
use App\Apply\Rollback;
use LaravelZero\Framework\Commands\Command;
use RuntimeException;

class RollbackCommand extends Command
{
    protected $signature = 'rollback {journal : Journal id printed by apply} {--yes : Confirm without asking}';

    protected $description = 'Undo a move recorded in a journal';

    public function handle(Rollback $rollback): int
    {
        if (! $this->option('yes') && ! $this->confirm('Undo the move recorded in '.$this->argument('journal').'?')) {
            return PlanCommand::INVALID;
        }

        try {
            $journal = Journal::fromFile(Journal::path(config('coolhop.home'), $this->argument('journal')));
            $rollback->run($journal, getenv('COOLHOP_BACKUP') ?: null);
        } catch (RuntimeException $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        $this->info('Rolled back '.$journal->id.'.');

        return self::SUCCESS;
    }
}
