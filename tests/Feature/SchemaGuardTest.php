<?php

use App\Schema\SchemaGuard;
use Tests\Support\Database;

afterEach(function () {
    $pdo = Database::pdo();
    $pdo->exec('alter table projects drop column if exists owner_team_id');
    $pdo->exec("delete from migrations where migration = '2099_01_01_000000_future'");
});

it('accepts the reference schema', function () {
    $result = SchemaGuard::check(Database::pdo());

    expect($result->canApply())->toBeTrue()
        ->and($result->versionSupported)->toBeTrue()
        ->and($result->unknownColumns)->toBe([]);
});

it('refuses an unknown team column', function () {
    Database::pdo()->exec('alter table projects add column owner_team_id bigint');

    $result = SchemaGuard::check(Database::pdo());

    expect($result->canApply())->toBeFalse()
        ->and($result->unknownColumns)->toBe(['projects.owner_team_id']);
});

it('refuses a schema older than the minimum', function () {
    $pdo = Database::pdo();
    $pdo->beginTransaction();
    $pdo->exec("delete from migrations where migration > '2026_08_15_000000_create_integration_tokens_table'");

    $result = SchemaGuard::check($pdo);
    $pdo->rollBack();

    expect($result->versionSupported)->toBeFalse()
        ->and($result->canApply())->toBeFalse();
});

it('accepts a newer schema when the guard passes', function () {
    Database::pdo()->exec("insert into migrations (migration, batch) values ('2099_01_01_000000_future', 999)");

    $result = SchemaGuard::check(Database::pdo());

    expect($result->versionSupported)->toBeTrue()
        ->and($result->lastMigration)->toBe('2099_01_01_000000_future');
});
