<?php

namespace App\Commands;

use App\Analysis\MovePlan;
use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\TeamVariablePolicy;
use App\Apply\Applier;
use App\Apply\Journal;
use App\Instance\Inventory;
use App\Output\PlanRenderer;
use App\Schema\SchemaGuard;
use Illuminate\Database\ConnectionInterface;
use Illuminate\Support\Str;
use LaravelZero\Framework\Commands\Command;
use RuntimeException;

use function Laravel\Prompts\multiselect;
use function Laravel\Prompts\select;
use function Laravel\Prompts\spin;
use function Laravel\Prompts\text;

class HopCommand extends Command
{
    protected $signature = 'hop';

    protected $description = 'Move servers between Coolify teams, step by step';

    public function handle(ConnectionInterface $db, Planner $planner, Applier $applier): int
    {
        if (! $this->input->isInteractive()) {
            $this->error('The guided mode needs a terminal. Use coolhop plan and coolhop apply with flags instead (coolhop plan --help).');

            return PlanCommand::INVALID;
        }

        $guard = SchemaGuard::check($db);
        $inventory = new Inventory($db);
        $teams = collect($inventory->teams())->keyBy('id');
        $servers = collect($inventory->servers());

        $owners = $teams->only($servers->pluck('teamId')->unique()->all());
        if ($owners->isEmpty()) {
            $this->info('No team owns a server that can move. Nothing to do.');

            return self::SUCCESS;
        }

        $from = (int) select('Which team do the servers belong to now?', $owners->map->name->all());
        $serverIds = array_values(array_map(intval(...), multiselect(
            'Which servers should move?',
            $servers->where('teamId', $from)->mapWithKeys(fn ($s): array => [$s->id => $s->name])->all(),
            required: true,
        )));
        $to = (int) select('Which team should receive them?', $teams->except([$from])->map->name->all());

        $fromTeam = $inventory->team($from);
        $toTeam = $inventory->team($to);
        $request = new MoveRequest($from, $to, $serverIds);
        $plan = spin(fn (): MovePlan => $planner->plan($request), 'Analysing');

        if (collect($plan->issues)->contains('code', 'team_variable_clash')) {
            $policy = select('Some team variables exist in both teams. What should happen?', [
                TeamVariablePolicy::KeepTarget->value => "Keep the values of {$toTeam->name}",
                TeamVariablePolicy::Stop->value => 'Stop, I will sort it out first',
            ]);
            $request = new MoveRequest($from, $to, $serverIds, [], TeamVariablePolicy::from($policy));
            $plan = $planner->plan($request);
        }

        if ($plan->unused !== []) {
            $take = multiselect(
                "Take these unused items of {$fromTeam->name} along?",
                collect($plan->unused)->mapWithKeys(fn ($u): array => ["{$u['table']}:{$u['id']}" => "{$u['table']}: {$u['name']}"])->all(),
            );
            if ($take !== []) {
                $request = new MoveRequest($from, $to, $serverIds, array_values(array_map(strval(...), $take)), $request->teamVariablePolicy);
                $plan = $planner->plan($request);
            }
        }

        new PlanRenderer($db)->render($plan, $this->output, $guard);

        if ($plan->hasBlockers() || ! $guard->canApply()) {
            $this->error('This move cannot be applied. Nothing was changed.');

            return self::FAILURE;
        }

        $target = $toTeam->name;
        if (text("Type {$target} to confirm") !== $target) {
            $this->warn('Confirmation did not match. Nothing was changed.');

            return self::FAILURE;
        }

        try {
            $journal = spin(fn (): Journal => $applier->apply($request, $plan->fingerprint(), getenv('COOLHOP_BACKUP') ?: null), 'Moving');
        } catch (RuntimeException $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        $this->info(sprintf('Moved %d %s to %s.', count($plan->servers), Str::plural('server', count($plan->servers)), $target));
        $this->line('Undo with: curl -fsSL '.config('coolhop.install_url').' | bash -s -- rollback '.$journal->id);

        return self::SUCCESS;
    }
}
