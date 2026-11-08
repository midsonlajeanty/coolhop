<?php

namespace App\Commands;

use App\Instance\Inventory;
use Illuminate\Database\ConnectionInterface;
use LaravelZero\Framework\Commands\Command;

class TeamsCommand extends Command
{
    protected $signature = 'teams';

    protected $description = 'List teams and the servers they own';

    public function handle(ConnectionInterface $db): int
    {
        $inventory = new Inventory($db);
        $servers = collect($inventory->servers())->groupBy('teamId');

        $rows = [];
        foreach ($inventory->teams() as $team) {
            $names = $servers->get($team->id, collect())->map(fn ($s): string => "{$s->name} ({$s->uuid})")->implode("\n");
            $rows[] = [$team->id, $team->name, $names ?: '-'];
        }

        $this->table(['ID', 'Team', 'Servers'], $rows);

        return self::SUCCESS;
    }
}
