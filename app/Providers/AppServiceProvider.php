<?php

namespace App\Providers;

use App\Database\ConnectionFactory;
use Illuminate\Support\ServiceProvider;
use PDO;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(PDO::class, fn () => ConnectionFactory::fromEnvironment());
    }
}
