<?php

use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Apply\Applier;
use App\Apply\CacheClearer;
use App\Security\Decryptor;
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

    $this->a = Fixture::team('A');
    $this->b = Fixture::team('B');
    $this->s1 = Fixture::server($this->a, 'S1');
    $this->web = Fixture::application(Fixture::environment(Fixture::project($this->a, 'P1')), Fixture::destination($this->s1));

    $planner = new Planner(DB::connection(), new Decryptor(Fixture::APP_KEY));
    $request = new MoveRequest($this->a, $this->b, [$this->s1]);
    $this->journal = new Applier(DB::connection(), $planner, new CacheClearer('/nonexistent'), $this->home)
        ->apply($request, $planner->plan($request)->fingerprint(), $this->backup);

    $this->left = [
        Fixture::auditEvent($this->a, 'server', Fixture::uuidOf('servers', $this->s1)),
        Fixture::auditEvent($this->a, 'application', Fixture::uuidOf('applications', $this->web)),
    ];
    $this->kept = Fixture::auditEvent($this->a, 'team', null);
});

afterEach(function (): void {
    putenv('COOLHOP_BACKUP');
    putenv('APP_KEY');
    exec('rm -rf '.escapeshellarg($this->home));
});

it('moves the history left behind by an earlier move', function (): void {
    $this->artisan('history', ['journal' => $this->journal->id, '--yes' => true])
        ->expectsOutputToContain('Moved 2 audit events')
        ->expectsOutputToContain('rollback')
        ->assertExitCode(0);

    expect(DB::table('audit_events')->whereIn('id', $this->left)->pluck('team_id')->unique()->all())->toBe([$this->b])
        ->and(DB::table('audit_events')->where('id', $this->kept)->value('team_id'))->toBe($this->a);
});

it('can be rolled back like any move', function (): void {
    $this->artisan('history', ['journal' => $this->journal->id, '--yes' => true])->assertExitCode(0);
    $id = collect(glob("{$this->home}/*/journal.json"))->map(fn ($p): string => basename(dirname($p)))->reject(fn ($j): bool => $j === $this->journal->id)->first();

    $this->artisan('rollback', ['journal' => $id, '--yes' => true])->assertExitCode(0);

    expect(DB::table('audit_events')->whereIn('id', $this->left)->pluck('team_id')->unique()->all())->toBe([$this->a]);
});

it('says when there is nothing to move', function (): void {
    DB::table('audit_events')->whereIn('id', $this->left)->update(['team_id' => $this->b]);

    $this->artisan('history', ['journal' => $this->journal->id, '--yes' => true])
        ->expectsOutputToContain('No audit events')
        ->assertExitCode(0);
});

it('refuses a rolled back journal', function (): void {
    $this->artisan('rollback', ['journal' => $this->journal->id, '--yes' => true])->assertExitCode(0);

    $this->artisan('history', ['journal' => $this->journal->id, '--yes' => true])
        ->expectsOutputToContain('rolled back')
        ->assertExitCode(1);
});

it('requires --yes without a terminal', function (): void {
    $this->artisan('history', ['journal' => $this->journal->id, '--no-interaction' => true])
        ->expectsOutputToContain('--yes')
        ->assertExitCode(2);
});
