<?php

use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

beforeEach(function () {
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
    Fixture::application(Fixture::environment(Fixture::project($this->agency, 'shop')), Fixture::destination($this->web1));
    $this->idle = Fixture::githubApp($this->agency, Fixture::privateKey($this->agency), 'idle-app');
});

afterEach(function () {
    putenv('COOLHOP_BACKUP');
    putenv('APP_KEY');
    exec('rm -rf '.escapeshellarg($this->home));
});

function guided($test)
{
    return $test->artisan('hop')
        ->expectsQuestion('Which team do the servers belong to now?', (string) $test->agency)
        ->expectsQuestion('Which servers should move?', [(string) $test->web1, (string) $test->web2])
        ->expectsQuestion('Which team should receive them?', '0')
        ->expectsQuestion('Take these unused items of Agency along?', ["github_apps:{$test->idle}"]);
}

it('moves servers through the guided flow', function () {
    guided($this)
        ->expectsQuestion('Type Platform to confirm', 'Platform')
        ->expectsOutputToContain('Moved 2 servers')
        ->expectsOutputToContain('install.sh | bash -s -- rollback')
        ->assertExitCode(0);

    expect(DB::table('servers')->where('id', $this->web1)->value('team_id'))->toBe(0)
        ->and(DB::table('github_apps')->where('name', 'idle-app')->value('team_id'))->toBe(0);
});

it('aborts on a wrong confirmation', function () {
    guided($this)
        ->expectsQuestion('Type Platform to confirm', 'nope')
        ->expectsOutputToContain('Nothing was changed')
        ->assertExitCode(1);

    expect(DB::table('servers')->where('id', $this->web1)->value('team_id'))->toBe($this->agency);
});

it('never asks for confirmation when the plan has blockers', function () {
    $p = DB::table('projects')->where('name', 'shop')->value('id');
    Fixture::database('standalone_postgresqls', Fixture::environment($p), Fixture::destination($this->web2));

    $this->artisan('hop')
        ->expectsQuestion('Which team do the servers belong to now?', (string) $this->agency)
        ->expectsQuestion('Which servers should move?', [(string) $this->web1])
        ->expectsQuestion('Which team should receive them?', '0')
        ->expectsQuestion('Take these unused items of Agency along?', [])
        ->expectsOutputToContain('Blockers')
        ->assertExitCode(1);
});

it('points to the flags when there is no terminal', function () {
    $this->artisan('hop', ['--no-interaction' => true])
        ->expectsOutputToContain('coolhop plan')
        ->assertExitCode(2);
});
