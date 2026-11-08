<?php

declare(strict_types=1);

namespace App\Commands;

use App\Output\PlanRenderer;
use App\Schema\SchemaGuard;
use Illuminate\Database\ConnectionInterface;
use LaravelZero\Framework\Commands\Command;

class CheckCommand extends Command
{
    protected $signature = 'check';

    protected $description = 'Check that coolhop supports this Coolify schema';

    public function handle(ConnectionInterface $db): int
    {
        $guard = SchemaGuard::check($db);
        $this->line('Last migration: '.$guard->lastMigration);

        if (! $guard->canApply()) {
            $this->error(PlanRenderer::guardMessage($guard));

            return self::FAILURE;
        }

        $this->info('This Coolify schema is supported.');

        return self::SUCCESS;
    }
}
