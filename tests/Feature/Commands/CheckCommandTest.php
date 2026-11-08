<?php

use Illuminate\Support\Facades\DB;

it('reports a supported schema', function (): void {
    $this->artisan('check')
        ->expectsOutputToContain('2026_11_01_142702_add_update_channel_to_instance_settings_table')
        ->expectsOutputToContain('supported')
        ->assertExitCode(0);
});

it('fails on an unknown team column', function (): void {
    DB::statement('alter table projects add column owner_team_id bigint');

    try {
        $this->artisan('check')->expectsOutputToContain('projects.owner_team_id')->assertExitCode(1);
    } finally {
        DB::statement('alter table projects drop column owner_team_id');
    }
});
