<?php

namespace App\Analysis;

use App\Analysis\Rules\ProjectRule;
use App\Analysis\Rules\Rule;
use App\Analysis\Rules\NoticeRule;
use App\Analysis\Rules\ServerRule;
use App\Analysis\Rules\SharedItemRule;
use App\Analysis\Rules\SharedVariableRule;
use App\Analysis\Rules\TagRule;
use App\Analysis\Rules\UnusedItemRule;
use App\Analysis\Rules\TopologyRule;
use App\Instance\Inventory;
use App\Instance\Server;
use App\Security\Decryptor;
use Illuminate\Database\ConnectionInterface;
use InvalidArgumentException;

final class Planner
{
    /** @var list<class-string<Rule>> */
    public const RULES = [
        ServerRule::class,
        ProjectRule::class,
        TopologyRule::class,
        SharedItemRule::class,
        UnusedItemRule::class,
        SharedVariableRule::class,
        TagRule::class,
        NoticeRule::class,
    ];

    private readonly Inventory $inventory;

    private readonly Decryptor $decryptor;

    public function __construct(private readonly ConnectionInterface $db, ?Decryptor $decryptor = null)
    {
        $this->inventory = new Inventory($db);
        $this->decryptor = $decryptor ?? Decryptor::fromEnvironment();
    }

    public function plan(MoveRequest $request): MovePlan
    {
        if ($request->fromTeamId === $request->toTeamId) {
            throw new InvalidArgumentException('Source and target teams must be different.');
        }
        if ($request->serverIds === []) {
            throw new InvalidArgumentException('Select at least one server.');
        }

        $from = $this->inventory->team($request->fromTeamId);
        $to = $this->inventory->team($request->toTeamId);
        $servers = $this->selectedServers($request, $from->name, $to->name);

        $builder = new PlanBuilder(
            $this->db,
            $this->inventory,
            $this->decryptor,
            $request,
            $from,
            $to,
            $servers,
            $this->inventory->resourcesOfTeam($from->id),
        );

        foreach (self::RULES as $rule) {
            (new $rule)->apply($builder);
        }

        return $builder->build();
    }

    /**
     * @return list<Server>
     */
    private function selectedServers(MoveRequest $request, string $fromName, string $toName): array
    {
        if (in_array(Inventory::LOCALHOST_SERVER_ID, $request->serverIds, true)) {
            throw new InvalidArgumentException('The localhost server cannot change team: Coolify ties it to the root team.');
        }

        $all = collect($this->inventory->servers())->keyBy('id');

        return array_map(function (int $id) use ($all, $request, $fromName, $toName) {
            $server = $all->get($id) ?? throw new InvalidArgumentException("Server {$id} does not exist.");

            return match ($server->teamId) {
                $request->fromTeamId => $server,
                $request->toTeamId => throw new InvalidArgumentException("Server {$server->name} already belongs to {$toName}."),
                default => throw new InvalidArgumentException("Server {$server->name} does not belong to {$fromName}."),
            };
        }, array_values(array_unique($request->serverIds)));
    }
}
