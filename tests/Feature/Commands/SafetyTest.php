<?php

use Illuminate\Support\Facades\Artisan;

it('never exposes destructive database commands', function (): void {
    $commands = array_keys(Artisan::all());

    expect($commands)->not->toContain('migrate', 'migrate:fresh', 'migrate:reset', 'migrate:refresh', 'migrate:rollback', 'db:wipe', 'db:seed');
});
