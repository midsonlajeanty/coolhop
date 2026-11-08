<?php

use App\Analysis\CopyRef;
use App\Analysis\IssueLevel;
use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\RowChange;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

function sharedPlan(MoveRequest $request)
{
    return (new Planner(DB::connection()))->plan($request);
}

function changed($plan, string $table, string $column = 'team_id'): array
{
    return collect($plan->changes)
        ->filter(fn (RowChange $c) => $c->table === $table && $c->column === $column)
        ->map(fn (RowChange $c) => [$c->key['id'], $c->new instanceof CopyRef ? $c->new->ref : $c->new])
        ->values()
        ->all();
}

function copied($plan): array
{
    return collect($plan->copies)->pluck('ref')->all();
}

beforeEach(function () {
    $this->a = Fixture::team('A');
    $this->b = Fixture::team('B');
    $this->key = Fixture::privateKey($this->a, 'server-key');
    $this->s1 = Fixture::server($this->a, 'S1', $this->key);
    $this->d1 = Fixture::destination($this->s1);
    $this->e1 = Fixture::environment(Fixture::project($this->a, 'P1'));
    $this->request = new MoveRequest($this->a, $this->b, [$this->s1]);
});

it('moves a private key used only by moving servers', function () {
    expect(changed(sharedPlan($this->request), 'private_keys'))->toBe([[$this->key, $this->b]]);
});

it('copies a private key shared with a staying server', function () {
    Fixture::server($this->a, 'S2', $this->key);

    $plan = sharedPlan($this->request);

    expect(copied($plan))->toBe(["private_keys:{$this->key}"])
        ->and(changed($plan, 'servers', 'private_key_id'))->toBe([[$this->s1, "private_keys:{$this->key}"]])
        ->and(changed($plan, 'private_keys'))->toBe([]);
});

it('copies a deploy key shared with a staying application', function () {
    $deployKey = Fixture::privateKey($this->a, 'deploy');
    $moving = Fixture::application($this->e1, $this->d1);
    $s2 = Fixture::server($this->a, 'S2');
    $staying = Fixture::application(Fixture::environment(Fixture::project($this->a, 'P2')), Fixture::destination($s2));
    DB::table('applications')->whereIn('id', [$moving, $staying])->update(['private_key_id' => $deployKey]);

    $plan = sharedPlan($this->request);

    expect(changed($plan, 'applications', 'private_key_id'))->toBe([[$moving, "private_keys:{$deployKey}"]]);
});

it('moves a github app used only by moving apps, with its key', function () {
    $appKey = Fixture::privateKey($this->a, 'gh-key');
    $github = Fixture::githubApp($this->a, $appKey);
    Fixture::application($this->e1, $this->d1, $github);

    $plan = sharedPlan($this->request);

    expect(changed($plan, 'github_apps'))->toBe([[$github, $this->b]])
        ->and(changed($plan, 'private_keys'))->toContain([$appKey, $this->b]);
});

it('blocks a github app shared with staying apps', function () {
    $github = Fixture::githubApp($this->a, Fixture::privateKey($this->a));
    Fixture::application($this->e1, $this->d1, $github);
    $s2 = Fixture::server($this->a, 'S2');
    Fixture::application(Fixture::environment(Fixture::project($this->a, 'P2')), Fixture::destination($s2), $github);

    $issue = collect(sharedPlan($this->request)->issues)->firstWhere('code', 'shared_git_app');

    expect($issue->level)->toBe(IssueLevel::Blocker)->and($issue->message)->toContain('github');
});

it('ignores system wide git apps', function () {
    $github = Fixture::githubApp($this->a, Fixture::privateKey($this->a), systemWide: true);
    Fixture::application($this->e1, $this->d1, $github);

    expect(changed(sharedPlan($this->request), 'github_apps'))->toBe([]);
});

it('moves an s3 storage used only by moving backups, with the backup', function () {
    $s3 = Fixture::s3($this->a);
    $db = Fixture::database('standalone_postgresqls', $this->e1, $this->d1);
    $backup = Fixture::backup($this->a, 'standalone_postgresqls', $db, $s3);

    $plan = sharedPlan($this->request);

    expect(changed($plan, 's3_storages'))->toBe([[$s3, $this->b]])
        ->and(changed($plan, 'scheduled_database_backups'))->toBe([[$backup, $this->b]]);
});

it('copies an s3 storage shared with a staying backup', function () {
    $s3 = Fixture::s3($this->a);
    $backup = Fixture::backup($this->a, 'standalone_postgresqls', Fixture::database('standalone_postgresqls', $this->e1, $this->d1), $s3);
    $s2 = Fixture::server($this->a, 'S2');
    Fixture::backup($this->a, 'standalone_postgresqls', Fixture::database('standalone_postgresqls', Fixture::environment(Fixture::project($this->a, 'P2')), Fixture::destination($s2)), $s3);

    $plan = sharedPlan($this->request);

    expect(copied($plan))->toContain("s3_storages:{$s3}")
        ->and(changed($plan, 'scheduled_database_backups', 's3_storage_id'))->toBe([[$backup, "s3_storages:{$s3}"]]);
});

it('does nothing for an s3 storage already in the target', function () {
    $s3 = Fixture::s3($this->b);
    Fixture::backup($this->a, 'standalone_postgresqls', Fixture::database('standalone_postgresqls', $this->e1, $this->d1), $s3);

    $plan = sharedPlan($this->request);

    expect(changed($plan, 's3_storages'))->toBe([])->and(copied($plan))->toBe([]);
});

it('moves a project icon storage with the project', function () {
    $s3 = Fixture::s3($this->a);
    Fixture::application($this->e1, $this->d1);
    DB::table('projects')->update(['icon_s3_storage_id' => $s3]);

    expect(changed(sharedPlan($this->request), 's3_storages'))->toBe([[$s3, $this->b]]);
});

it('moves a cloud provider token used only by moving servers', function () {
    $token = Fixture::insert('cloud_provider_tokens', ['uuid' => Fixture::uuid(), 'team_id' => $this->a, 'provider' => 'hetzner', 'token' => 't']);
    DB::table('servers')->where('id', $this->s1)->update(['cloud_provider_token_id' => $token]);

    expect(changed(sharedPlan($this->request), 'cloud_provider_tokens'))->toBe([[$token, $this->b]]);
});

it('moves scheduled tasks and volume backups with their resource', function () {
    $app = Fixture::application($this->e1, $this->d1);
    $task = Fixture::insert('scheduled_tasks', ['uuid' => Fixture::uuid(), 'name' => 't', 'command' => 'ls', 'frequency' => '* * * * *', 'team_id' => $this->a, 'application_id' => $app]);
    $volume = Fixture::insert('scheduled_volume_backups', ['uuid' => Fixture::uuid(), 'backupable_type' => 'App\Models\Application', 'backupable_id' => $app, 'team_id' => $this->a, 'frequency' => '0 0 * * *']);

    $plan = sharedPlan($this->request);

    expect(changed($plan, 'scheduled_tasks'))->toBe([[$task, $this->b]])
        ->and(changed($plan, 'scheduled_volume_backups'))->toBe([[$volume, $this->b]]);
});

it('lists unused items of the source team', function () {
    $unusedKey = Fixture::privateKey($this->a, 'orphan-key');
    $github = Fixture::githubApp($this->a, Fixture::privateKey($this->a, 'gh-key'), 'idle-app');
    Fixture::s3($this->a, 'idle-bucket');

    $unused = collect(sharedPlan($this->request)->unused)->map(fn ($u) => "{$u['table']}:{$u['name']}")->all();

    expect($unused)->toEqualCanonicalizing(['private_keys:orphan-key', 'github_apps:idle-app', 's3_storages:idle-bucket']);
});

it('moves unused items named in the request', function () {
    $ghKey = Fixture::privateKey($this->a, 'gh-key');
    $github = Fixture::githubApp($this->a, $ghKey, 'idle-app');

    $plan = sharedPlan(new MoveRequest($this->a, $this->b, [$this->s1], ["github_apps:{$github}"]));

    expect(changed($plan, 'github_apps'))->toBe([[$github, $this->b]])
        ->and(changed($plan, 'private_keys'))->toContain([$ghKey, $this->b])
        ->and(collect($plan->unused)->pluck('id')->all())->not->toContain($github);
});
