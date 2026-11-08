<?php

use App\Analysis\IssueLevel;
use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\RowChange;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

function plan(MoveRequest $request)
{
    return (new Planner(DB::connection()))->plan($request);
}

function changesOf($plan, string $table, string $column = 'team_id'): array
{
    return collect($plan->changes)
        ->filter(fn (RowChange $c) => $c->table === $table && $c->column === $column)
        ->map(fn (RowChange $c) => [$c->key['id'] ?? $c->key, $c->old, $c->new])
        ->values()
        ->all();
}

function codes($plan, IssueLevel $level): array
{
    return collect($plan->issues)->where('level', $level)->pluck('code')->values()->all();
}

beforeEach(function () {
    $this->a = Fixture::team('A');
    $this->b = Fixture::team('B');
    $this->s1 = Fixture::server($this->a, 'S1');
    $this->s2 = Fixture::server($this->a, 'S2');
    $this->d1 = Fixture::destination($this->s1);
    $this->d2 = Fixture::destination($this->s2);
});

it('moves selected servers', function () {
    $plan = plan(new MoveRequest($this->a, $this->b, [$this->s1]));

    expect(changesOf($plan, 'servers'))->toBe([[$this->s1, $this->a, $this->b]])
        ->and($plan->hasBlockers())->toBeFalse();
});

it('moves a project whose resources are all on moving servers', function () {
    $p1 = Fixture::project($this->a, 'P1');
    Fixture::application(Fixture::environment($p1), $this->d1);

    $plan = plan(new MoveRequest($this->a, $this->b, [$this->s1]));

    expect(changesOf($plan, 'projects'))->toBe([[$p1, $this->a, $this->b]]);
});

it('blocks a mixed project', function () {
    $p2 = Fixture::project($this->a, 'Mixed');
    $e = Fixture::environment($p2);
    Fixture::application($e, $this->d1);
    Fixture::database('standalone_postgresqls', $e, $this->d2);

    $plan = plan(new MoveRequest($this->a, $this->b, [$this->s1]));
    $issue = collect($plan->issues)->firstWhere('code', 'mixed_project');

    expect($issue->level)->toBe(IssueLevel::Blocker)
        ->and($issue->message)->toContain('Mixed', 'S1', 'S2')
        ->and($plan->hasBlockers())->toBeTrue();
});

it('leaves empty projects in the source team', function () {
    Fixture::project($this->a, 'Empty');

    expect(changesOf(plan(new MoveRequest($this->a, $this->b, [$this->s1])), 'projects'))->toBe([]);
});

it('blocks unknown destination types', function () {
    $e = Fixture::environment(Fixture::project($this->a, 'P'));
    Fixture::database('standalone_redis', $e, $this->d1, destinationType: 'App\Models\FutureDocker');

    $issue = collect(plan(new MoveRequest($this->a, $this->b, [$this->s1]))->issues)->firstWhere('code', 'unknown_destination');

    expect($issue->level)->toBe(IssueLevel::Blocker)
        ->and($issue->message)->toContain('standalone_redis', 'App\Models\FutureDocker');
});

it('blocks split additional destinations', function () {
    $app = Fixture::application(Fixture::environment(Fixture::project($this->a, 'P')), $this->d1);
    Fixture::insert('additional_destinations', ['application_id' => $app, 'server_id' => $this->s2, 'standalone_docker_id' => $this->d2]);

    expect(codes(plan(new MoveRequest($this->a, $this->b, [$this->s1])), IssueLevel::Blocker))->toContain('split_destinations');
});

it('blocks moving a build server that staying apps still need', function () {
    $builder = Fixture::server($this->a, 'Builder', settings: ['is_build_server' => 'true']);
    Fixture::application(Fixture::environment(Fixture::project($this->a, 'Stay')), $this->d2, settings: ['is_build_server_enabled' => 'true']);

    expect(codes(plan(new MoveRequest($this->a, $this->b, [$builder])), IssueLevel::Blocker))->toBe(['build_server']);
});

it('blocks moving apps that need a build server the target lacks', function () {
    Fixture::application(Fixture::environment(Fixture::project($this->a, 'P')), $this->d1, settings: ['is_build_server_enabled' => 'true']);

    expect(codes(plan(new MoveRequest($this->a, $this->b, [$this->s1])), IssueLevel::Blocker))->toBe(['build_server']);
});

it('blocks a split swarm', function () {
    $manager = Fixture::server($this->a, 'Manager', settings: ['is_swarm_manager' => 'true']);
    Fixture::server($this->a, 'Worker', settings: ['is_swarm_worker' => 'true']);

    expect(codes(plan(new MoveRequest($this->a, $this->b, [$manager])), IssueLevel::Blocker))->toBe(['split_swarm']);
});

it('blocks active deployments', function (string $status) {
    $app = Fixture::application(Fixture::environment(Fixture::project($this->a, 'P')), $this->d1);
    Fixture::deployment($app, $status);

    expect(codes(plan(new MoveRequest($this->a, $this->b, [$this->s1])), IssueLevel::Blocker))->toBe(['active_deployment']);
})->with(['queued', 'in_progress']);

it('ignores finished deployments', function () {
    $app = Fixture::application(Fixture::environment(Fixture::project($this->a, 'P')), $this->d1);
    Fixture::deployment($app, 'finished');

    expect(plan(new MoveRequest($this->a, $this->b, [$this->s1]))->hasBlockers())->toBeFalse();
});

it('rejects servers outside the source team', function () {
    $other = Fixture::server(Fixture::team('C'), 'Other');

    plan(new MoveRequest($this->a, $this->b, [$other]));
})->throws(InvalidArgumentException::class, 'does not belong to A');

it('rejects the localhost server', function () {
    Fixture::server($this->a, 'localhost', id: 0);

    plan(new MoveRequest($this->a, $this->b, [0]));
})->throws(InvalidArgumentException::class, 'localhost');

it('reports servers already in the target', function () {
    $moved = Fixture::server($this->b, 'Moved');

    plan(new MoveRequest($this->a, $this->b, [$moved]));
})->throws(InvalidArgumentException::class, 'already belongs to B');

it('rejects the same source and target', function () {
    plan(new MoveRequest($this->a, $this->a, [$this->s1]));
})->throws(InvalidArgumentException::class, 'different');

it('rejects an empty selection', function () {
    plan(new MoveRequest($this->a, $this->b, []));
})->throws(InvalidArgumentException::class, 'at least one server');

it('gives the same fingerprint for the same state', function () {
    Fixture::application(Fixture::environment(Fixture::project($this->a, 'P')), $this->d1);
    $request = new MoveRequest($this->a, $this->b, [$this->s1]);

    expect(plan($request)->fingerprint())->toBe(plan($request)->fingerprint());
});
