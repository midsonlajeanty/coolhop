<?php

namespace App\Analysis;

final class References
{
    public const GIT_APPS = [
        'github_apps' => 'App\Models\GithubApp',
        'gitlab_apps' => 'App\Models\GitlabApp',
        'gitea_apps' => 'App\Models\GiteaApp',
    ];

    /**
     * Shared items and every column that points to them, as [table, column, morph type column, morph type].
     *
     * @var array<string, list<array{0: string, 1: string, 2?: string, 3?: string}>>
     */
    public const SHARED = [
        'github_apps' => [['applications', 'source_id', 'source_type', 'App\Models\GithubApp']],
        'gitlab_apps' => [['applications', 'source_id', 'source_type', 'App\Models\GitlabApp']],
        'gitea_apps' => [['applications', 'source_id', 'source_type', 'App\Models\GiteaApp']],
        's3_storages' => [
            ['scheduled_database_backups', 's3_storage_id'],
            ['scheduled_volume_backups', 's3_storage_id'],
            ['scheduled_database_backup_s3_storage', 's3_storage_id'],
            ['scheduled_volume_backup_s3_storage', 's3_storage_id'],
            ['projects', 'icon_s3_storage_id'],
        ],
        'cloud_provider_tokens' => [['servers', 'cloud_provider_token_id']],
        'private_keys' => [
            ['servers', 'private_key_id'],
            ['applications', 'private_key_id'],
            ['github_apps', 'private_key_id'],
            ['gitlab_apps', 'private_key_id'],
            ['gitea_apps', 'private_key_id'],
        ],
    ];

    public const COPYABLE = ['s3_storages', 'cloud_provider_tokens', 'private_keys'];
}
