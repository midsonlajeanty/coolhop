<?php

namespace App\Commands;

use App\Analysis\Planner;
use App\Commands\Concerns\ResolvesTeams;
use App\Instance\Inventory;
use App\Output\PlanJson;
use App\Output\PlanRenderer;
use App\Schema\SchemaGuard;
use Illuminate\Database\ConnectionInterface;
use InvalidArgumentException;
use LaravelZero\Framework\Commands\Command;

class PlanCommand extends Command
{
    use ResolvesTeams;

    public const INVALID = 2;

    protected $signature = 'plan
        {--from= : Source team, by name or id}
        {--to= : Target team, by name or id}
        {--server=* : Server to move, by name or uuid}
        {--take=* : Unused item of the source team to take along, as table:id}
        {--on-variable-clash=keep : keep or stop when a team variable exists in both teams}
        {--json : Print the plan as JSON}';

    protected $description = 'Show what moving servers would change, without writing anything';

    public function handle(ConnectionInterface $db, Planner $planner): int
    {
        try {
            $plan = $planner->plan($this->requestFromOptions(new Inventory($db)));
        } catch (InvalidArgumentException $e) {
            $this->error($e->getMessage());

            return self::INVALID;
        }

        $guard = SchemaGuard::check($db);

        if ($this->option('json')) {
            $this->line(json_encode(PlanJson::from($plan, $guard), JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR));
        } else {
            new PlanRenderer($db)->render($plan, $this->output, $guard);
        }

        return $plan->hasBlockers() ? self::FAILURE : self::SUCCESS;
    }
}
