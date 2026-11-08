<?php

use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Apply\Applier;
use App\Apply\CacheClearer;
use App\Apply\Journal;
use App\Security\Decryptor;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

beforeEach(function () {
    $this->home = sys_get_temp_dir().'/coolhop-test-'.bin2hex(random_bytes(4));
    mkdir($this->home);
    $this->backup = $this->home.'/coolify.dump';
    file_put_contents($this->backup, 'dump');

    $this->a = Fixture::team('A');
    $this->b = Fixture::team('B');
    $this->key = Fixture::privateKey($this->a, 'shared');
    $this->s1 = Fixture::server($this->a, 'S1', $this->key);
    Fixture::server($this->a, 'S2', $this->key);
    $this->d1 = Fixture::destination($this->s1);
    $this->p1 = Fixture::project($this->a, 'P1');
    Fixture::application(Fixture::environment($this->p1), $this->d1);

    $this->planner = new Planner(DB::connection(), new Decryptor(Fixture::APP_KEY));
    $this->applier = new Applier(DB::connection(), $this->planner, new CacheClearer('/nonexistent/artisan'), $this->home);
    $this->request = new MoveRequest($this->a, $this->b, [$this->s1]);
});

afterEach(function () {
    DB::unprepared('drop trigger if exists coolhop_fail on projects; drop function if exists coolhop_fail();');
    exec('rm -rf '.escapeshellarg($this->home));
});

it('applies a plan and writes a journal', function () {
    $fingerprint = $this->planner->plan($this->request)->fingerprint();

    $journal = $this->applier->apply($this->request, $fingerprint, $this->backup);

    $server = DB::table('servers')->find($this->s1);
    $copy = DB::table('private_keys')->find($server->private_key_id);

    expect($server->team_id)->toBe($this->b)
        ->and(DB::table('projects')->find($this->p1)->team_id)->toBe($this->b)
        ->and($copy->id)->not->toBe($this->key)
        ->and($copy->team_id)->toBe($this->b)
        ->and($copy->uuid)->not->toBe(DB::table('private_keys')->find($this->key)->uuid)
        ->and(DB::table('private_keys')->find($this->key)->team_id)->toBe($this->a)
        ->and($journal->created)->toBe([['table' => 'private_keys', 'id' => $copy->id, 'ref' => "private_keys:{$this->key}"]])
        ->and(count($journal->changes))->toBe(3)
        ->and(Journal::fromFile("{$this->home}/{$journal->id}/journal.json")->changes)->toBe($journal->changes);
});

it('rolls back everything on failure', function () {
    DB::unprepared("create function coolhop_fail() returns trigger as \$\$ begin raise exception 'boom'; end \$\$ language plpgsql;
        create trigger coolhop_fail before update on projects for each row execute function coolhop_fail();");
    $fingerprint = $this->planner->plan($this->request)->fingerprint();

    expect(fn () => $this->applier->apply($this->request, $fingerprint, $this->backup))->toThrow(Exception::class, 'boom');

    expect(DB::table('servers')->find($this->s1)->team_id)->toBe($this->a)
        ->and(DB::table('private_keys')->count())->toBe(1)
        ->and(glob("{$this->home}/*/journal.json"))->toBe([]);
});

it('aborts when the plan changed since confirmation', function () {
    $fingerprint = $this->planner->plan($this->request)->fingerprint();
    Fixture::application(Fixture::environment(Fixture::project($this->a, 'Late')), $this->d1);

    expect(fn () => $this->applier->apply($this->request, $fingerprint, $this->backup))
        ->toThrow(RuntimeException::class, 'changed since the plan');

    expect(DB::table('servers')->find($this->s1)->team_id)->toBe($this->a);
});

it('refuses a plan with blockers', function () {
    $s2 = DB::table('servers')->where('name', 'S2')->value('id');
    $e = Fixture::environment($this->p1);
    Fixture::database('standalone_postgresqls', $e, Fixture::destination($s2));
    $fingerprint = $this->planner->plan($this->request)->fingerprint();

    expect(fn () => $this->applier->apply($this->request, $fingerprint, $this->backup))
        ->toThrow(RuntimeException::class, 'blockers');
});

it('refuses without a backup', function () {
    $fingerprint = $this->planner->plan($this->request)->fingerprint();

    expect(fn () => $this->applier->apply($this->request, $fingerprint, ''))->toThrow(RuntimeException::class, 'Backup missing');
});

it('refuses a stale backup', function () {
    touch($this->backup, time() - 7200);
    $fingerprint = $this->planner->plan($this->request)->fingerprint();

    expect(fn () => $this->applier->apply($this->request, $fingerprint, $this->backup))
        ->toThrow(RuntimeException::class, 'Backup older than one hour');
});

it('writes nothing when the journal cannot be saved', function () {
    $readOnly = $this->home.'/readonly';
    mkdir($readOnly, 0500);
    $applier = new Applier(DB::connection(), $this->planner, new CacheClearer('/nonexistent/artisan'), $readOnly);
    $fingerprint = $this->planner->plan($this->request)->fingerprint();

    try {
        expect(fn () => $applier->apply($this->request, $fingerprint, $this->backup))->toThrow(RuntimeException::class, 'journal');
    } finally {
        chmod($readOnly, 0700);
    }

    expect(DB::table('servers')->find($this->s1)->team_id)->toBe($this->a)
        ->and(DB::table('private_keys')->count())->toBe(1);
});
