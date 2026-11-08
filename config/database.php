<?php

return [
    'default' => 'coolify',
    'connections' => [
        'coolify' => [
            'driver' => 'pgsql',
            'host' => env('DB_HOST', 'coolify-db'),
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'coolify'),
            'username' => env('DB_USERNAME', 'coolify'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => 'utf8',
            'prefix' => '',
            'search_path' => 'public',
            'sslmode' => 'prefer',
        ],
    ],
    'migrations' => 'coolhop_migrations',
];
