<?php

use Tests\Support\Database;
use Tests\Support\Fixture;

it('loads the coolify schema at the reference migration', function () {
    $last = Database::pdo()->query('select max(migration) from migrations')->fetchColumn();

    expect($last)->toBe('2026_11_01_142702_add_update_channel_to_instance_settings_table');
});

it('starts every test from empty tables', function () {
    $teamId = Fixture::team('A');

    expect($teamId)->toBeInt()
        ->and((int) Database::pdo()->query('select count(*) from teams')->fetchColumn())->toBe(1);
});
