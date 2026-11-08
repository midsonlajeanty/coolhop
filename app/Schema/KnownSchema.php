<?php

declare(strict_types=1);

namespace App\Schema;

final class KnownSchema
{
    public const string MIN_MIGRATION = '2026_11_01_142702_add_update_channel_to_instance_settings_table';

    public const array OWNERSHIP_COLUMNS = [
        'audit_events.team_id',
        'cloud_init_scripts.team_id',
        'cloud_provider_tokens.team_id',
        'discord_notification_settings.team_id',
        'email_notification_settings.team_id',
        'gitea_apps.team_id',
        'github_apps.team_id',
        'gitlab_apps.team_id',
        'integration_tokens.team_id',
        'managed_dns_records.team_id',
        'personal_access_tokens.team_id',
        'private_keys.team_id',
        'projects.team_id',
        'pushover_notification_settings.team_id',
        's3_storages.team_id',
        'scheduled_database_backups.team_id',
        'scheduled_tasks.team_id',
        'scheduled_volume_backups.team_id',
        'servers.team_id',
        'shared_environment_variables.team_id',
        'slack_notification_settings.team_id',
        'subscriptions.team_id',
        'tags.team_id',
        'team_invitations.team_id',
        'team_user.team_id',
        'telegram_notification_settings.team_id',
        'users.current_team_id',
        'webhook_notification_settings.team_id',
    ];

    public const array FOREIGN_KEYS = [
        'additional_destinations.server_id->servers',
        'cloud_init_scripts.team_id->teams',
        'cloud_provider_tokens.team_id->teams',
        'database_backup_s3_replicas.s3_storage_id->s3_storages',
        'discord_notification_settings.team_id->teams',
        'dns_provider_zones.integration_token_id->integration_tokens',
        'email_notification_settings.team_id->teams',
        'github_runner_configs.github_app_id->github_apps',
        'github_runner_configs.server_id->servers',
        'github_runner_executions.github_app_id->github_apps',
        'github_runner_executions.server_id->servers',
        'instance_settings.avatar_s3_storage_id->s3_storages',
        'instance_settings.file_download_s3_storage_id->s3_storages',
        'integration_tokens.team_id->teams',
        'managed_dns_records.integration_token_id->integration_tokens',
        'managed_dns_records.team_id->teams',
        'projects.icon_s3_storage_id->s3_storages',
        'pushover_notification_settings.team_id->teams',
        'resource_links.environment_id->environments',
        'scheduled_database_backup_s3_storage.s3_storage_id->s3_storages',
        'scheduled_volume_backup_executions.s3_storage_id->s3_storages',
        'scheduled_volume_backup_s3_storage.s3_storage_id->s3_storages',
        'scheduled_volume_backups.s3_storage_id->s3_storages',
        'scheduled_volume_backups.team_id->teams',
        'secret_manager_links.integration_token_id->integration_tokens',
        'server_settings.cloudflare_tunnel_integration_token_id->integration_tokens',
        'servers.cloud_provider_token_id->cloud_provider_tokens',
        'shared_environment_variables.environment_id->environments',
        'shared_environment_variables.project_id->projects',
        'shared_environment_variables.server_id->servers',
        'shared_environment_variables.team_id->teams',
        'slack_notification_settings.team_id->teams',
        'ssl_certificates.server_id->servers',
        'taggables.tag_id->tags',
        'tags.team_id->teams',
        'team_invitations.team_id->teams',
        'teams.avatar_s3_storage_id->s3_storages',
        'telegram_notification_settings.team_id->teams',
        'users.avatar_s3_storage_id->s3_storages',
        'volume_backup_s3_replicas.s3_storage_id->s3_storages',
        'webhook_notification_settings.team_id->teams',
    ];

    public const array IGNORED_TABLES = ['telescope_entries', 'telescope_entries_tags', 'telescope_monitoring'];

    public const array GUARDED_TABLES = [
        'teams', 'servers', 'private_keys', 'github_apps', 'gitlab_apps', 'gitea_apps', 's3_storages',
        'cloud_provider_tokens', 'integration_tokens', 'projects', 'environments', 'tags',
    ];

    public const array RESOURCE_TABLES = [
        'applications' => 'App\Models\Application',
        'services' => 'App\Models\Service',
        'standalone_postgresqls' => 'App\Models\StandalonePostgresql',
        'standalone_redis' => 'App\Models\StandaloneRedis',
        'standalone_mysqls' => 'App\Models\StandaloneMysql',
        'standalone_mariadbs' => 'App\Models\StandaloneMariadb',
        'standalone_mongodbs' => 'App\Models\StandaloneMongodb',
        'standalone_keydbs' => 'App\Models\StandaloneKeydb',
        'standalone_dragonflies' => 'App\Models\StandaloneDragonfly',
        'standalone_clickhouses' => 'App\Models\StandaloneClickhouse',
        'standalone_sqlites' => 'App\Models\StandaloneSqlite',
    ];

    public const array DESTINATION_TYPES = [
        'App\Models\StandaloneDocker' => 'standalone_dockers',
        'App\Models\SwarmDocker' => 'swarm_dockers',
    ];
}
