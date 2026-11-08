<?php

namespace App\Commands;

use App\Analysis\Planner;
use App\Apply\Applier;
use App\Commands\Concerns\ResolvesTeams;
use App\Instance\Inventory;
use App\Output\PlanRenderer;
use App\Schema\SchemaGuard;
use Illuminate\Database\ConnectionInterface;
use InvalidArgumentException;
use Illuminate\Support\Str;
use LaravelZero\Framework\Commands\Command;
use RuntimeException;

class ApplyCommand extends Command
{
    use ResolvesTeams;

    protected $signature = 'apply
        {--from= : Source team, by name or id}
        {--to= : Target team, by name or id}
        {--server=* : Server to move, by name or uuid}
        {--take=* : Unused item of the source team to take along, as table:id}
        {--on-variable-clash=keep : keep or stop when a team variable exists in both teams}
        {--yes : Confirm without asking}';

    protected $description = 'Move servers to another team';

    public function handle(ConnectionInterface $db, Planner $planner, Applier $applier): int
    {
        if (! $this->option('yes')) {
            $this->error('apply changes the Coolify database. Pass --yes, or run coolhop without arguments for the guided mode.');

            return PlanCommand::INVALID;
        }

        $guard = SchemaGuard::check($db);
        
        if (! $guard->canApply()) {
            $this->error('Refusing to apply on this schema. '.PlanRenderer::guardMessage($guard));

            return self::FAILURE;
        }

        try {
            $request = $this->requestFromOptions(new Inventory($db));
            $plan = $planner->plan($request);
        } catch (InvalidArgumentException $e) {
            $this->error($e->getMessage());

            return PlanCommand::INVALID;
        }

        (new PlanRenderer($db))->render($plan, $this->output);

        try {
            $journal = $applier->apply($request, $plan->fingerprint(), getenv('COOLHOP_BACKUP') ?: null);
        } catch (RuntimeException $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        $this->info(sprintf('Moved %d %s to %s.', count($plan->servers), Str::plural('server', count($plan->servers)), $plan->to->name));
        $this->line('Journal: '.$journal->id);
        $this->line('Undo with: curl -fsSL '.config('coolhop.install_url').' | bash -s -- rollback '.$journal->id);

        return self::SUCCESS;
    }
}
