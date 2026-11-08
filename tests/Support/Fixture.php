<?php

namespace Tests\Support;

use Illuminate\Encryption\Encrypter;

final class Fixture
{
    public const APP_KEY = 'base64:a2tra2tra2tra2tra2tra2tra2tra2tra2tra2tra2s=';

    public static function insert(string $table, array $values): int
    {
        $columns = array_keys($values);
        $sql = sprintf(
            'insert into %s (%s) values (%s) returning id',
            $table,
            implode(', ', $columns),
            implode(', ', array_map(fn ($c) => ':'.$c, $columns)),
        );
        $statement = Database::pdo()->prepare($sql);
        $statement->execute($values);

        return (int) $statement->fetchColumn();
    }

    public static function team(string $name, ?int $id = null): int
    {
        return self::insert('teams', array_filter(['id' => $id, 'name' => $name], fn ($v) => $v !== null));
    }

    public static function server(int $teamId, string $name, ?int $privateKeyId = null, array $settings = [], ?int $id = null): int
    {
        $values = [
            'uuid' => self::uuid(),
            'name' => $name,
            'ip' => '10.0.0.'.random_int(1, 254),
            'team_id' => $teamId,
            'private_key_id' => $privateKeyId ?? self::privateKey($teamId),
        ];
        if ($id !== null) {
            $values['id'] = $id;
        }
        $serverId = self::insert('servers', $values);
        self::insert('server_settings', ['server_id' => $serverId, ...$settings]);

        return $serverId;
    }

    public static function destination(int $serverId): int
    {
        return self::insert('standalone_dockers', [
            'uuid' => self::uuid(),
            'name' => 'coolify',
            'network' => 'coolify',
            'server_id' => $serverId,
        ]);
    }

    public static function project(int $teamId, string $name): int
    {
        $projectId = self::insert('projects', ['uuid' => self::uuid(), 'name' => $name, 'team_id' => $teamId]);
        self::insert('environments', ['uuid' => self::uuid(), 'name' => 'production', 'project_id' => $projectId]);

        return $projectId;
    }

    public static function environment(int $projectId): int
    {
        return (int) Database::pdo()
            ->query("select id from environments where project_id = {$projectId} order by id limit 1")
            ->fetchColumn();
    }

    public static function application(int $environmentId, int $destinationId, ?int $githubAppId = null, array $settings = [], string $name = 'app'): int
    {
        $values = [
            'uuid' => self::uuid(),
            'name' => $name,
            'git_repository' => 'acme/app',
            'git_branch' => 'main',
            'build_pack' => 'nixpacks',
            'environment_id' => $environmentId,
            'destination_id' => $destinationId,
            'destination_type' => 'App\Models\StandaloneDocker',
        ];
        if ($githubAppId !== null) {
            $values['source_id'] = $githubAppId;
            $values['source_type'] = 'App\Models\GithubApp';
        }
        $applicationId = self::insert('applications', $values);
        self::insert('application_settings', ['application_id' => $applicationId, ...$settings]);

        return $applicationId;
    }

    public static function service(int $environmentId, int $destinationId, string $name = 'service'): int
    {
        $serverId = (int) Database::pdo()
            ->query("select server_id from standalone_dockers where id = {$destinationId}")
            ->fetchColumn();

        return self::insert('services', [
            'uuid' => self::uuid(),
            'name' => $name,
            'docker_compose_raw' => 'services: {}',
            'environment_id' => $environmentId,
            'destination_id' => $destinationId,
            'destination_type' => 'App\Models\StandaloneDocker',
            'server_id' => $serverId,
        ]);
    }

    public static function database(string $table, int $environmentId, int $destinationId, string $name = 'db', string $destinationType = 'App\Models\StandaloneDocker'): int
    {
        $values = [
            'uuid' => self::uuid(),
            'name' => $name,
            'environment_id' => $environmentId,
            'destination_id' => $destinationId,
            'destination_type' => $destinationType,
        ];
        if ($table === 'standalone_postgresqls') {
            $values['postgres_password'] = 'secret';
        }

        return self::insert($table, $values);
    }

    public static function privateKey(int $teamId, string $name = 'key'): int
    {
        return self::insert('private_keys', [
            'uuid' => self::uuid(),
            'name' => $name,
            'private_key' => 'encrypted',
            'team_id' => $teamId,
        ]);
    }

    public static function githubApp(int $teamId, int $privateKeyId, string $name = 'github', bool $systemWide = false): int
    {
        return self::insert('github_apps', [
            'uuid' => self::uuid(),
            'name' => $name,
            'api_url' => 'https://api.github.com',
            'html_url' => 'https://github.com',
            'team_id' => $teamId,
            'private_key_id' => $privateKeyId,
            'is_system_wide' => $systemWide ? 'true' : 'false',
        ]);
    }

    public static function s3(int $teamId, string $name = 's3'): int
    {
        return self::insert('s3_storages', [
            'uuid' => self::uuid(),
            'name' => $name,
            'key' => 'k',
            'secret' => 's',
            'bucket' => 'b',
            'team_id' => $teamId,
        ]);
    }

    public static function backup(int $teamId, string $databaseTable, int $databaseId, ?int $s3Id): int
    {
        return self::insert('scheduled_database_backups', array_filter([
            'uuid' => self::uuid(),
            'team_id' => $teamId,
            'frequency' => '0 0 * * *',
            'database_type' => 'App\Models\\'.self::morphClass($databaseTable),
            'database_id' => $databaseId,
            's3_storage_id' => $s3Id,
        ], fn ($v) => $v !== null));
    }

    public static function sharedVariable(int $teamId, string $type, string $key, array $scope = [], string $value = 'value'): int
    {
        return self::insert('shared_environment_variables', [
            'key' => $key,
            'value' => self::encrypt($value),
            'type' => $type,
            'team_id' => $teamId,
            ...$scope,
        ]);
    }

    public static function tag(int $teamId, string $name, string $taggableType, int $taggableId): int
    {
        $existing = Database::pdo()->prepare('select id from tags where team_id = ? and name = ?');
        $existing->execute([$teamId, $name]);
        $tagId = (int) $existing->fetchColumn() ?: self::insert('tags', ['uuid' => self::uuid(), 'name' => $name, 'team_id' => $teamId]);

        Database::pdo()->prepare('insert into taggables (tag_id, taggable_id, taggable_type) values (?, ?, ?)')
            ->execute([$tagId, $taggableId, $taggableType]);

        return $tagId;
    }

    public static function envVar(string $resourceType, int $resourceId, string $key, string $plainValue): int
    {
        return self::insert('environment_variables', [
            'uuid' => self::uuid(),
            'key' => $key,
            'value' => self::encrypt($plainValue),
            'resourceable_type' => $resourceType,
            'resourceable_id' => $resourceId,
        ]);
    }

    public static function deployment(int $applicationId, string $status): int
    {
        return self::insert('application_deployment_queues', [
            'deployment_uuid' => self::uuid(),
            'application_id' => (string) $applicationId,
            'status' => $status,
        ]);
    }

    public static function token(int $teamId, string $name): int
    {
        return self::insert('personal_access_tokens', [
            'tokenable_type' => 'App\Models\User',
            'tokenable_id' => 0,
            'name' => $name,
            'token' => bin2hex(random_bytes(16)),
            'team_id' => (string) $teamId,
        ]);
    }

    public static function encrypt(string $value): string
    {
        return (new Encrypter(base64_decode(substr(self::APP_KEY, 7)), 'aes-256-cbc'))->encryptString($value);
    }

    public static function uuid(): string
    {
        return substr(str_shuffle(str_repeat('abcdefghijklmnopqrstuvwxyz0123456789', 2)), 0, 24);
    }

    private static function morphClass(string $table): string
    {
        return [
            'standalone_postgresqls' => 'StandalonePostgresql',
            'standalone_redis' => 'StandaloneRedis',
            'standalone_mysqls' => 'StandaloneMysql',
            'standalone_mariadbs' => 'StandaloneMariadb',
            'standalone_mongodbs' => 'StandaloneMongodb',
        ][$table];
    }
}
