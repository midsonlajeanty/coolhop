<?php

namespace App\Commands\Concerns;

use App\Analysis\MoveRequest;
use App\Analysis\TeamVariablePolicy;
use App\Instance\Inventory;
use App\Instance\Team;
use InvalidArgumentException;

trait ResolvesTeams
{
    protected function resolveTeam(Inventory $inventory, ?string $value): Team
    {
        $value = trim((string) $value);
        foreach ($inventory->teams() as $team) {
            if ((string) $team->id === $value || strcasecmp($team->name, $value) === 0) {
                return $team;
            }
        }

        throw new InvalidArgumentException("No team matches \"{$value}\". Run coolhop teams to see them.");
    }

    /**
     * @param  list<string>  $values
     * @return list<int>
     */
    protected function resolveServers(Inventory $inventory, array $values): array
    {
        $servers = $inventory->servers();

        return array_map(function (string $value) use ($servers) {
            foreach ($servers as $server) {
                if ($server->uuid === $value || strcasecmp($server->name, $value) === 0 || (string) $server->id === $value) {
                    return $server->id;
                }
            }

            throw new InvalidArgumentException("No server matches \"{$value}\". Run coolhop teams to see them.");
        }, $values);
    }

    protected function requestFromOptions(Inventory $inventory): MoveRequest
    {
        $servers = $this->stringOptions('server');
        if ($servers === []) {
            throw new InvalidArgumentException('Pass at least one --server.');
        }

        return new MoveRequest(
            $this->resolveTeam($inventory, $this->option('from'))->id,
            $this->resolveTeam($inventory, $this->option('to'))->id,
            $this->resolveServers($inventory, $servers),
            $this->stringOptions('take'),
            TeamVariablePolicy::tryFrom((string) ($this->option('on-variable-clash') ?? 'keep'))
                ?? throw new InvalidArgumentException('--on-variable-clash must be keep or stop.'),
        );
    }

    /**
     * @return list<string>
     */
    private function stringOptions(string $name): array
    {
        return array_values(array_filter((array) $this->option($name), is_string(...)));
    }
}
