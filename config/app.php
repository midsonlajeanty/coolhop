<?php

use App\Providers\AppServiceProvider;

return [
    'name' => 'coolhop',
    'version' => app('git.version'),
    'env' => 'development',
    'providers' => [
        AppServiceProvider::class,
    ],
];
