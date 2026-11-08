<?php

namespace App\Instance;

use App\Schema\KnownSchema;
use Illuminate\Database\ConnectionInterface;
use Illuminate\Database\Query\JoinClause;
use InvalidArgumentException;

final readonly class Inventory
{
    public const int LOCALHOST_SERVER_ID = 0;

    public function __construct(private ConnectionInterface $db) {}

    /**
     * @return list<Team>
     */
    public function teams(): array
    {
        return array_values($this->db->table('teams')->orderBy('id')->get(['id', 'name'])
            ->map(fn ($row): Team => new Team((int) $row->id, $row->name))
            ->all());
    }

    public function team(int $id): Team
    {
        $row = $this->db->table('teams')->where('id', $id)->first(['id', 'name']);

        return $row ? new Team((int) $row->id, $row->name) : throw new InvalidArgumentException("Team {$id} does not exist.");
    }

    /**
     * @return list<Server>
     */
    public function servers(?int $teamId = null): array
    {
        return array_values($this->db->table('servers as s')
            ->leftJoin('server_settings as ss', 'ss.server_id', '=', 's.id')
            ->where('s.id', '<>', self::LOCALHOST_SERVER_ID)
            ->when($teamId !== null, fn ($q) => $q->where('s.team_id', $teamId))
            ->orderBy('s.id')
            ->get(['s.*', 'ss.is_build_server', 'ss.is_swarm_manager', 'ss.is_swarm_worker'])
            ->map(fn ($row): Server => new Server(
                id: (int) $row->id,
                uuid: $row->uuid,
                name: $row->name,
                ip: $row->ip,
                teamId: (int) $row->team_id,
                privateKeyId: $row->private_key_id === null ? null : (int) $row->private_key_id,
                cloudProviderTokenId: $row->cloud_provider_token_id === null ? null : (int) $row->cloud_provider_token_id,
                isBuildServer: (bool) $row->is_build_server,
                isSwarmManager: (bool) $row->is_swarm_manager,
                isSwarmWorker: (bool) $row->is_swarm_worker,
            ))
            ->all());
    }

    /**
     * @return list<HostedResource>
     */
    public function resourcesOfTeam(int $teamId): array
    {
        return array_merge(...array_map(
            fn (string $table): array => $this->resourcesIn($table, $teamId),
            array_keys(KnownSchema::RESOURCE_TABLES),
        ));
    }

    /**
     * @return list<HostedResource>
     */
    private function resourcesIn(string $table, int $teamId): array
    {
        [$standalone, $swarm] = array_keys(KnownSchema::DESTINATION_TYPES);

        return array_values($this->db->table("{$table} as r")
            ->join('environments as e', 'e.id', '=', 'r.environment_id')
            ->join('projects as p', 'p.id', '=', 'e.project_id')
            ->leftJoin('standalone_dockers as sd', fn (JoinClause $j) => $j->on('sd.id', '=', 'r.destination_id')->where('r.destination_type', $standalone))
            ->leftJoin('swarm_dockers as sw', fn (JoinClause $j) => $j->on('sw.id', '=', 'r.destination_id')->where('r.destination_type', $swarm))
            ->whereNull('r.deleted_at')
            ->where('p.team_id', $teamId)
            ->orderBy('r.id')
            ->get(['r.id', 'r.name', 'r.environment_id', 'r.destination_type', 'e.project_id', 'p.team_id', 'sd.server_id as standalone_server_id', 'sw.server_id as swarm_server_id'])
            ->map(fn ($row): HostedResource => new HostedResource(
                table: $table,
                id: (int) $row->id,
                name: $row->name,
                environmentId: (int) $row->environment_id,
                projectId: (int) $row->project_id,
                teamId: (int) $row->team_id,
                serverId: ($server = $row->standalone_server_id ?? $row->swarm_server_id) === null ? null : (int) $server,
                unknownDestinationType: isset(KnownSchema::DESTINATION_TYPES[$row->destination_type]) ? null : $row->destination_type,
            ))
            ->all());
    }
}
