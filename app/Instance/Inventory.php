<?php

namespace App\Instance;

use App\Schema\KnownSchema;
use PDO;

final class Inventory
{
    public const LOCALHOST_SERVER_ID = 0;

    public function __construct(private readonly PDO $pdo) {}

    /**
     * @return list<Team>
     */
    public function teams(): array
    {
        return array_map(
            fn (array $row) => new Team((int) $row['id'], $row['name']),
            $this->pdo->query('select id, name from teams order by id')->fetchAll(),
        );
    }

    public function team(int $id): Team
    {
        foreach ($this->teams() as $team) {
            if ($team->id === $id) {
                return $team;
            }
        }

        throw new \InvalidArgumentException("Team {$id} does not exist.");
    }

    /**
     * @return list<Server>
     */
    public function servers(?int $teamId = null): array
    {
        $statement = $this->pdo->prepare(
            'select s.id, s.uuid, s.name, s.ip, s.team_id, s.private_key_id, s.cloud_provider_token_id,
                    coalesce(ss.is_build_server, false) as is_build_server,
                    coalesce(ss.is_swarm_manager, false) as is_swarm_manager,
                    coalesce(ss.is_swarm_worker, false) as is_swarm_worker
             from servers s
             left join server_settings ss on ss.server_id = s.id
             where s.id <> :localhost and (cast(:team as bigint) is null or s.team_id = cast(:team as bigint))
             order by s.id'
        );
        $statement->execute(['localhost' => self::LOCALHOST_SERVER_ID, 'team' => $teamId]);

        return array_map(fn (array $row) => new Server(
            id: (int) $row['id'],
            uuid: $row['uuid'],
            name: $row['name'],
            ip: $row['ip'],
            teamId: (int) $row['team_id'],
            privateKeyId: $row['private_key_id'] === null ? null : (int) $row['private_key_id'],
            cloudProviderTokenId: $row['cloud_provider_token_id'] === null ? null : (int) $row['cloud_provider_token_id'],
            isBuildServer: (bool) $row['is_build_server'],
            isSwarmManager: (bool) $row['is_swarm_manager'],
            isSwarmWorker: (bool) $row['is_swarm_worker'],
        ), $statement->fetchAll());
    }

    /**
     * @return list<Resource>
     */
    public function resourcesOfTeam(int $teamId): array
    {
        $resources = [];
        foreach (array_keys(KnownSchema::RESOURCE_TABLES) as $table) {
            foreach ($this->resourcesIn($table, $teamId) as $resource) {
                $resources[] = $resource;
            }
        }

        return $resources;
    }

    /**
     * @return list<Resource>
     */
    private function resourcesIn(string $table, int $teamId): array
    {
        $statement = $this->pdo->prepare(
            "select r.id, r.name, r.environment_id, e.project_id, p.team_id, r.destination_type,
                    case r.destination_type
                        when 'App\\Models\\StandaloneDocker' then sd.server_id
                        when 'App\\Models\\SwarmDocker' then sw.server_id
                    end as server_id
             from {$table} r
             join environments e on e.id = r.environment_id
             join projects p on p.id = e.project_id
             left join standalone_dockers sd on sd.id = r.destination_id
             left join swarm_dockers sw on sw.id = r.destination_id
             where r.deleted_at is null and p.team_id = :team
             order by r.id"
        );
        $statement->execute(['team' => $teamId]);

        return array_map(fn (array $row) => new Resource(
            table: $table,
            id: (int) $row['id'],
            name: $row['name'],
            environmentId: (int) $row['environment_id'],
            projectId: (int) $row['project_id'],
            teamId: (int) $row['team_id'],
            serverId: $row['server_id'] === null ? null : (int) $row['server_id'],
            unknownDestinationType: isset(KnownSchema::DESTINATION_TYPES[$row['destination_type']]) ? null : $row['destination_type'],
        ), $statement->fetchAll());
    }
}
