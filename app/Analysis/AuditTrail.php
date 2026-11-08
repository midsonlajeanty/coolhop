<?php

declare(strict_types=1);

namespace App\Analysis;

use App\Schema\KnownSchema;
use Illuminate\Database\ConnectionInterface;

final readonly class AuditTrail
{
    private const array TABLES_WITH_UUID = [
        'servers', 'projects', 'private_keys', 'github_apps', 'gitlab_apps', 'gitea_apps', 's3_storages',
        'cloud_provider_tokens', 'scheduled_database_backups', 'scheduled_volume_backups', 'scheduled_tasks',
    ];

    private const array SERVICE_PARTS = [
        'service_applications' => 'App\Models\ServiceApplication',
        'service_databases' => 'App\Models\ServiceDatabase',
    ];

    public function __construct(private ConnectionInterface $db) {}

    /**
     * @param  array<string, list<int>>  $moved  rows whose team changes, by table
     * @return list<int>
     */
    public function eventIds(int $teamId, array $moved): array
    {
        $uuids = $this->uuids($moved);
        if ($uuids === []) {
            return [];
        }

        return array_values($this->db->table('audit_events')
            ->where('team_id', $teamId)
            ->whereIn('resource_uuid', $uuids)
            ->orderBy('id')
            ->pluck('id')
            ->map(fn ($id): int => (int) $id)
            ->all());
    }

    /**
     * @param  array<string, list<int>>  $moved
     * @return list<string>
     */
    private function uuids(array $moved): array
    {
        $uuids = [];
        foreach (self::TABLES_WITH_UUID as $table) {
            array_push($uuids, ...$this->uuidsOf($table, 'id', $moved[$table] ?? []));
        }

        $servers = $moved['servers'] ?? [];
        array_push($uuids, ...$this->uuidsOf('standalone_dockers', 'server_id', $servers));
        array_push($uuids, ...$this->uuidsOf('swarm_dockers', 'server_id', $servers));

        $environments = $this->idsOf('environments', 'project_id', $moved['projects'] ?? []);
        array_push($uuids, ...$this->uuidsOf('environments', 'id', $environments));

        $morphs = [];
        foreach (KnownSchema::RESOURCE_TABLES as $table => $morph) {
            $ids = $this->idsOf($table, 'environment_id', $environments);
            $morphs[$morph] = $ids;
            array_push($uuids, ...$this->uuidsOf($table, 'id', $ids));
        }

        foreach (self::SERVICE_PARTS as $table => $morph) {
            $ids = $this->idsOf($table, 'service_id', $morphs['App\Models\Service']);
            $morphs[$morph] = $ids;
            array_push($uuids, ...$this->uuidsOf($table, 'id', $ids));
        }

        foreach ($morphs as $morph => $ids) {
            if ($ids !== []) {
                array_push($uuids, ...$this->db->table('environment_variables')
                    ->where('resourceable_type', $morph)->whereIn('resourceable_id', $ids)
                    ->pluck('uuid')->map(fn ($u): string => (string) $u)->all());
            }
        }

        $applications = array_map(strval(...), $morphs['App\Models\Application']);
        if ($applications !== []) {
            array_push($uuids, ...$this->db->table('application_deployment_queues')
                ->whereIn('application_id', $applications)
                ->pluck('deployment_uuid')->map(fn ($u): string => (string) $u)->all());
        }

        return array_values(array_unique($uuids));
    }

    /**
     * @param  list<int>  $values
     * @return list<int>
     */
    private function idsOf(string $table, string $column, array $values): array
    {
        if ($values === []) {
            return [];
        }

        return array_values($this->db->table($table)->whereIn($column, $values)->pluck('id')->map(fn ($id): int => (int) $id)->all());
    }

    /**
     * @param  list<int>  $values
     * @return list<string>
     */
    private function uuidsOf(string $table, string $column, array $values): array
    {
        if ($values === []) {
            return [];
        }

        return array_values($this->db->table($table)->whereIn($column, $values)->pluck('uuid')->map(fn ($u): string => (string) $u)->all());
    }
}
