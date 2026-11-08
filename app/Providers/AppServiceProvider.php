<?php

namespace App\Providers;

use App\Analysis\Planner;
use App\Apply\Applier;
use App\Apply\CacheClearer;
use App\Apply\Rollback;
use App\Security\Decryptor;
use Illuminate\Database\ConnectionInterface;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(ConnectionInterface::class, fn ($app) => $app['db']->connection());
        $this->app->bind(Decryptor::class, fn (): Decryptor => Decryptor::fromEnvironment());
        $this->app->bind(Planner::class, fn ($app): Planner => new Planner($app[ConnectionInterface::class], $app[Decryptor::class]));
        $this->app->bind(Applier::class, fn ($app): Applier => new Applier(
            $app[ConnectionInterface::class],
            $app[Planner::class],
            new CacheClearer,
            config('coolhop.home'),
        ));
        $this->app->bind(Rollback::class, fn ($app): Rollback => new Rollback($app[ConnectionInterface::class], new CacheClearer, config('coolhop.home')));
    }
}
