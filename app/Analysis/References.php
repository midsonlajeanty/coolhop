<?php

declare(strict_types=1);

namespace App\Analysis;

final class References
{
    public const array GIT_APPS = [
        'github_apps' => 'App\Models\GithubApp',
        'gitlab_apps' => 'App\Models\GitlabApp',
        'gitea_apps' => 'App\Models\GiteaApp',
    ];

    public const array COPYABLE = ['s3_storages', 'cloud_provider_tokens', 'private_keys'];

    /**
     * @return array<string, list<Reference>>
     */
    public static function shared(): array
    {
        return [
            'github_apps' => [new Reference('applications', 'source_id', 'source_type', 'App\Models\GithubApp')],
            'gitlab_apps' => [new Reference('applications', 'source_id', 'source_type', 'App\Models\GitlabApp')],
            'gitea_apps' => [new Reference('applications', 'source_id', 'source_type', 'App\Models\GiteaApp')],
            's3_storages' => [
                new Reference('scheduled_database_backups', 's3_storage_id'),
                new Reference('scheduled_volume_backups', 's3_storage_id'),
                new Reference('scheduled_database_backup_s3_storage', 's3_storage_id'),
                new Reference('scheduled_volume_backup_s3_storage', 's3_storage_id'),
                new Reference('projects', 'icon_s3_storage_id'),
            ],
            'cloud_provider_tokens' => [new Reference('servers', 'cloud_provider_token_id')],
            'private_keys' => [
                new Reference('servers', 'private_key_id'),
                new Reference('applications', 'private_key_id'),
                new Reference('github_apps', 'private_key_id'),
                new Reference('gitlab_apps', 'private_key_id'),
                new Reference('gitea_apps', 'private_key_id'),
            ],
        ];
    }

    /**
     * @return list<Reference>
     */
    public static function to(string $table): array
    {
        return self::shared()[$table] ?? ($table === 'tags' ? [new Reference('taggables', 'tag_id')] : []);
    }
}
