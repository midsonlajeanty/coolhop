<?php

use App\Providers\AppServiceProvider;
use Illuminate\Database\DatabaseServiceProvider;

return [
    'name' => 'coolhop',
    'version' => app('git.version'),
    'env' => Phar::running() !== '' ? 'production' : (env('APP_ENV') === 'testing' ? 'testing' : 'development'),
    'providers' => [
        DatabaseServiceProvider::class,
        AppServiceProvider::class,
    ],
];
