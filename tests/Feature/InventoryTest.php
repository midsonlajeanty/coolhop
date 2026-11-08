<?php

use App\Instance\Inventory;
use Illuminate\Support\Facades\DB;
use Tests\Support\Database;
use Tests\Support\Fixture;

beforeEach(function () {
    $this->inventory = new Inventory(DB::connection());
});

it('lists teams', function () {
    Fixture::team('A');
    Fixture::team('B');

    expect(array_map(fn ($t) => $t->name, $this->inventory->teams()))->toBe(['A', 'B']);
});

it('never lists the localhost server', function () {
    $a = Fixture::team('A', id: 0);
    Fixture::server($a, 'localhost', id: 0);
    Fixture::server($a, 'remote');

    expect(array_map(fn ($s) => $s->name, $this->inventory->servers()))->toBe(['remote']);
});

it('reads server settings', function () {
    $a = Fixture::team('A');
    Fixture::server($a, 'builder', settings: ['is_build_server' => 'true', 'is_swarm_worker' => 'true']);

    $server = $this->inventory->servers($a)[0];

    expect($server->isBuildServer)->toBeTrue()
        ->and($server->isSwarmWorker)->toBeTrue()
        ->and($server->isSwarmManager)->toBeFalse();
});

it('resolves the server of every resource', function () {
    $a = Fixture::team('A');
    $s = Fixture::server($a, 'S');
    $d = Fixture::destination($s);
    $p = Fixture::project($a, 'P');
    $e = Fixture::environment($p);
    Fixture::application($e, $d, name: 'web');
    Fixture::database('standalone_postgresqls', $e, $d, name: 'pg');
    Fixture::service($e, $d, name: 'svc');

    $resources = $this->inventory->resourcesOfTeam($a);

    expect(collect($resources)->pluck('serverId', 'name')->all())->toBe(['web' => $s, 'svc' => $s, 'pg' => $s])
        ->and($resources[0]->projectId)->toBe($p)
        ->and($resources[0]->teamId)->toBe($a);
});

it('flags unknown destination types', function () {
    $a = Fixture::team('A');
    $d = Fixture::destination(Fixture::server($a, 'S'));
    $e = Fixture::environment(Fixture::project($a, 'P'));
    Fixture::database('standalone_redis', $e, $d, name: 'cache', destinationType: 'App\Models\FutureDocker');

    $resource = $this->inventory->resourcesOfTeam($a)[0];

    expect($resource->serverId)->toBeNull()
        ->and($resource->unknownDestinationType)->toBe('App\Models\FutureDocker');
});

it('skips soft deleted resources', function () {
    $a = Fixture::team('A');
    $d = Fixture::destination(Fixture::server($a, 'S'));
    $e = Fixture::environment(Fixture::project($a, 'P'));
    $id = Fixture::application($e, $d);
    Database::pdo()->exec("update applications set deleted_at = now() where id = {$id}");

    expect($this->inventory->resourcesOfTeam($a))->toBe([]);
});
