<?php

use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

beforeEach(function (): void {
    $this->home = sys_get_temp_dir().'/coolhop-test-'.bin2hex(random_bytes(4));
    mkdir($this->home);
    $this->backup = $this->home.'/coolify.dump';
    file_put_contents($this->backup, 'dump');
    config()->set('coolhop.home', $this->home);
    putenv("COOLHOP_BACKUP={$this->backup}");
    putenv('APP_KEY='.Fixture::APP_KEY);

    $platform = Fixture::team('Platform', id: 0);
    Fixture::server($platform, 'localhost', id: 0);
    $this->agency = Fixture::team('Agency');
    $this->web1 = Fixture::server($this->agency, 'web-1');
    $this->web2 = Fixture::server($this->agency, 'web-2');
    $p = Fixture::project($this->agency, 'shop');
    Fixture::application(Fixture::environment($p), Fixture::destination($this->web1), name: 'shop');
    Fixture::service(Fixture::environment(Fixture::project($this->agency, 'INFRA')), Fixture::destination($this->web2), name: 'monitor');
    Fixture::token($this->agency, 'CI deploy');
});

afterEach(function (): void {
    putenv('COOLHOP_BACKUP');
    putenv('APP_KEY');
    exec('rm -rf '.escapeshellarg($this->home));
});

function moveArgs(): array
{
    return ['--from' => 'Agency', '--to' => 'Platform', '--server' => ['web-1', 'web-2']];
}

it('lists teams and servers without localhost', function (): void {
    $this->artisan('teams')
        ->expectsOutputToContain('Agency')
        ->expectsOutputToContain('web-2')
        ->doesntExpectOutputToContain('localhost')
        ->assertExitCode(0);
});

it('prints a plan', function (): void {
    $this->artisan('plan', moveArgs())
        ->expectsOutputToContain('Moves')
        ->expectsOutputToContain('web-1')
        ->expectsOutputToContain('After the move')
        ->expectsOutputToContain('CI deploy')
        ->assertExitCode(0);
});

it('accepts team ids and server uuids', function (): void {
    $uuid = DB::table('servers')->where('id', $this->web1)->value('uuid');

    $this->artisan('plan', ['--from' => (string) $this->agency, '--to' => '0', '--server' => [$uuid]])->assertExitCode(0);
});

it('exits 1 on blockers', function (): void {
    $p = DB::table('projects')->where('name', 'shop')->value('id');
    Fixture::database('standalone_postgresqls', Fixture::environment($p), Fixture::destination($this->web2));

    $this->artisan('plan', ['--from' => 'Agency', '--to' => 'Platform', '--server' => ['web-1']])
        ->expectsOutputToContain('Blockers')
        ->assertExitCode(1);
});

it('exits 2 on unknown names', function (): void {
    $this->artisan('plan', ['--from' => 'NOPE', '--to' => 'Platform', '--server' => ['web-1']])
        ->expectsOutputToContain('NOPE')
        ->assertExitCode(2);
});

it('prints the plan as json', function (): void {
    expect(Artisan::call('plan', [...moveArgs(), '--json' => true]))->toBe(0);

    $json = json_decode(Artisan::output(), true);

    expect($json)->toHaveKeys(['from', 'to', 'servers', 'changes', 'copies', 'issues', 'unused', 'fingerprint']);
});

it('requires --yes to apply', function (): void {
    $this->artisan('apply', moveArgs())->assertExitCode(2);

    expect(DB::table('servers')->where('id', $this->web1)->value('team_id'))->toBe($this->agency);
});

it('refuses to apply with a stale backup', function (): void {
    touch($this->backup, time() - 7200);

    $this->artisan('apply', [...moveArgs(), '--yes' => true, '--replan' => true])
        ->expectsOutputToContain('Backup')
        ->assertExitCode(1);
});

it('applies then rolls back', function (): void {
    $this->artisan('apply', [...moveArgs(), '--yes' => true, '--replan' => true])
        ->expectsOutputToContain('Moved 2 servers')
        ->assertExitCode(0);
    expect(DB::table('servers')->where('id', $this->web1)->value('team_id'))->toBe(0);

    $id = basename(dirname(glob("{$this->home}/*/journal.json")[0]));
    $this->artisan('rollback', ['journal' => $id, '--yes' => true])->assertExitCode(0);

    expect(DB::table('servers')->where('id', $this->web1)->value('team_id'))->toBe($this->agency);
});

it('refuses to apply on an unknown schema but still plans', function (): void {
    DB::statement('alter table projects add column owner_team_id bigint');

    try {
        $this->artisan('plan', moveArgs())->expectsOutputToContain('projects.owner_team_id')->assertExitCode(0);
        $this->artisan('apply', [...moveArgs(), '--yes' => true, '--replan' => true])->expectsOutputToContain('schema')->assertExitCode(1);
    } finally {
        DB::statement('alter table projects drop column owner_team_id');
    }
});

it('uses the singular for one server', function (): void {
    $this->artisan('apply', ['--from' => 'Agency', '--to' => 'Platform', '--server' => ['web-2'], '--yes' => true, '--replan' => true])
        ->expectsOutputToContain('Moved 1 server to Platform.')
        ->assertExitCode(0);
});

it('requires the reviewed fingerprint or --replan', function (): void {
    $this->artisan('apply', [...moveArgs(), '--yes' => true])
        ->expectsOutputToContain('--fingerprint')
        ->assertExitCode(2);
});

it('refuses a fingerprint that no longer matches', function (): void {
    $this->artisan('apply', [...moveArgs(), '--yes' => true, '--fingerprint' => str_repeat('0', 64)])
        ->expectsOutputToContain('changed since the plan')
        ->assertExitCode(1);
});

it('applies with the fingerprint printed by plan', function (): void {
    Artisan::call('plan', [...moveArgs(), '--json' => true]);
    $fingerprint = json_decode(Artisan::output(), true)['fingerprint'];

    $this->artisan('apply', [...moveArgs(), '--yes' => true, '--fingerprint' => $fingerprint])->assertExitCode(0);
});

it('prints the fingerprint in the plan', function (): void {
    $this->artisan('plan', moveArgs())->expectsOutputToContain('--fingerprint=')->assertExitCode(0);
});

it('rejects an invalid variable clash policy', function (): void {
    $this->artisan('plan', [...moveArgs(), '--on-variable-clash' => 'bogus'])
        ->expectsOutputToContain('keep or stop')
        ->assertExitCode(2);
});

it('tells how to confirm a rollback without a terminal', function (): void {
    $this->artisan('rollback', ['journal' => 'x', '--no-interaction' => true])
        ->expectsOutputToContain('--yes')
        ->assertExitCode(2);
});
