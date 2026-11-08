<?php

use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Apply\Applier;
use App\Apply\CacheClearer;
use App\Apply\Journal;
use App\Apply\Rollback;
use App\Apply\RollbackConflict;
use App\Security\Decryptor;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

function snapshot(): array
{
    return collect(['servers', 'projects', 'private_keys', 'tags', 'taggables', 'shared_environment_variables'])
        ->mapWithKeys(fn ($t) => [$t => DB::table($t)->get()->map(fn ($r) => (array) $r)->sortBy(fn ($r) => json_encode($r))->values()->all()])
        ->all();
}

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
    $d1 = Fixture::destination($this->s1);
    $app = Fixture::application(Fixture::environment(Fixture::project($this->a, 'P1')), $d1);
    Fixture::tag($this->a, 'web', 'App\Models\Application', $app);

    $planner = new Planner(DB::connection(), new Decryptor(Fixture::APP_KEY));
    $request = new MoveRequest($this->a, $this->b, [$this->s1]);
    $this->before = snapshot();
    $this->journal = (new Applier(DB::connection(), $planner, new CacheClearer('/nonexistent'), $this->home))
        ->apply($request, $planner->plan($request)->fingerprint(), $this->backup);
    $this->rollback = new Rollback(DB::connection(), new CacheClearer('/nonexistent'), $this->home);
});

afterEach(fn () => exec('rm -rf '.escapeshellarg($this->home)));

it('restores the previous state', function () {
    $this->rollback->run($this->journal, $this->backup);

    $after = snapshot();

    expect($after)->toEqual($this->before)
        ->and(DB::table('servers')->find($this->s1)->team_id)->toBe($this->a)
        ->and(DB::table('servers')->find($this->s1)->private_key_id)->toBe($this->key)
        ->and(Journal::fromFile(Journal::path($this->home, $this->journal->id))->rolledBackAt)->not->toBeNull();
});

it('refuses when a row changed since the move', function () {
    DB::table('servers')->where('id', $this->s1)->update(['team_id' => $this->a]);

    expect(fn () => $this->rollback->run($this->journal, $this->backup))->toThrow(RollbackConflict::class, 'servers');

    expect(DB::table('projects')->where('team_id', $this->b)->count())->toBe(1);
});

it('refuses when a copy is now used by something new', function () {
    $copy = DB::table('servers')->find($this->s1)->private_key_id;
    Fixture::server($this->b, 'New', $copy);

    expect(fn () => $this->rollback->run($this->journal, $this->backup))->toThrow(RollbackConflict::class, 'private_keys');
});

it('refuses to roll back twice', function () {
    $this->rollback->run($this->journal, $this->backup);

    $journal = Journal::fromFile(Journal::path($this->home, $this->journal->id));

    expect(fn () => $this->rollback->run($journal, $this->backup))->toThrow(RollbackConflict::class, 'already rolled back');
});

it('requires a fresh backup', function () {
    expect(fn () => $this->rollback->run($this->journal, null))->toThrow(RuntimeException::class, 'Backup missing');
});
