<?php

use App\Analysis\CopyRef;
use App\Analysis\IssueLevel;
use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\RowChange;
use App\Analysis\TeamVariablePolicy;
use App\Security\Decryptor;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

function vtnPlan(MoveRequest $request)
{
    return (new Planner(DB::connection(), new Decryptor(Fixture::APP_KEY)))->plan($request);
}

function issue($plan, string $code)
{
    return collect($plan->issues)->firstWhere('code', $code);
}

beforeEach(function () {
    $this->a = Fixture::team('A');
    $this->b = Fixture::team('B');
    $this->s1 = Fixture::server($this->a, 'S1');
    $this->d1 = Fixture::destination($this->s1);
    $this->p1 = Fixture::project($this->a, 'P1');
    $this->e1 = Fixture::environment($this->p1);
    $this->web = Fixture::application($this->e1, $this->d1, name: 'web');
    $this->request = new MoveRequest($this->a, $this->b, [$this->s1]);
});

it('moves server, project and environment variables with their owner', function () {
    $server = Fixture::sharedVariable($this->a, 'server', 'COOLIFY_SERVER_UUID', ['server_id' => $this->s1]);
    $project = Fixture::sharedVariable($this->a, 'project', 'P', ['project_id' => $this->p1]);
    $environment = Fixture::sharedVariable($this->a, 'environment', 'E', ['environment_id' => $this->e1]);

    $moved = collect(vtnPlan($this->request)->changes)
        ->where('table', 'shared_environment_variables')
        ->map(fn (RowChange $c) => $c->key['id'])
        ->values()->all();

    expect($moved)->toEqualCanonicalizing([$server, $project, $environment]);
});

it('copies team variables referenced by moving resources', function () {
    $flux = Fixture::sharedVariable($this->a, 'team', 'FLUX_USERNAME');
    $license = Fixture::sharedVariable($this->a, 'team', 'FLUX_LICENSE_KEY');
    Fixture::sharedVariable($this->a, 'team', 'UNUSED');
    Fixture::envVar('App\Models\Application', $this->web, 'A', 'x{{team.FLUX_USERNAME}}y');
    Fixture::envVar('App\Models\Application', $this->web, 'B', '{{ team.FLUX_LICENSE_KEY }}');

    $copies = collect(vtnPlan($this->request)->copies)->pluck('ref')->all();

    expect($copies)->toEqualCanonicalizing(["shared_environment_variables:{$flux}", "shared_environment_variables:{$license}"]);
});

it('keeps the target value on a clash', function () {
    Fixture::sharedVariable($this->a, 'team', 'FLUX_USERNAME');
    Fixture::sharedVariable($this->b, 'team', 'FLUX_USERNAME');
    Fixture::envVar('App\Models\Application', $this->web, 'A', '{{team.FLUX_USERNAME}}');

    $plan = vtnPlan($this->request);

    expect(issue($plan, 'team_variable_clash')->level)->toBe(IssueLevel::Warning)
        ->and($plan->copies)->toBe([]);
});

it('blocks on a clash when asked to stop', function () {
    Fixture::sharedVariable($this->a, 'team', 'FLUX_USERNAME');
    Fixture::sharedVariable($this->b, 'team', 'FLUX_USERNAME');
    Fixture::envVar('App\Models\Application', $this->web, 'A', '{{team.FLUX_USERNAME}}');

    $plan = vtnPlan(new MoveRequest($this->a, $this->b, [$this->s1], teamVariablePolicy: TeamVariablePolicy::Stop));

    expect(issue($plan, 'team_variable_clash')->level)->toBe(IssueLevel::Blocker);
});

it('warns about references to team variables that do not exist', function () {
    Fixture::envVar('App\Models\Application', $this->web, 'A', '{{team.MISSING}}');

    expect(issue(vtnPlan($this->request), 'missing_team_variable')->level)->toBe(IssueLevel::Warning);
});

it('copies a tag the target lacks and repoints the resource', function () {
    $tag = Fixture::tag($this->a, 'django', 'App\Models\Application', $this->web);

    $plan = vtnPlan($this->request);
    $change = collect($plan->changes)->firstWhere('table', 'taggables');

    expect(collect($plan->copies)->pluck('ref')->all())->toBe(["tags:{$tag}"])
        ->and($change->key)->toBe(['tag_id' => $tag, 'taggable_id' => $this->web, 'taggable_type' => 'App\Models\Application'])
        ->and($change->new)->toEqual(new CopyRef("tags:{$tag}"));
});

it('reuses a tag the target already has', function () {
    Fixture::tag($this->a, 'django', 'App\Models\Application', $this->web);
    $targetTag = Fixture::insert('tags', ['uuid' => Fixture::uuid(), 'name' => 'django', 'team_id' => $this->b]);

    $plan = vtnPlan($this->request);

    expect($plan->copies)->toBe([])
        ->and(collect($plan->changes)->firstWhere('table', 'taggables')->new)->toBe($targetTag);
});

it('blocks references that coolhop cannot move', function (Closure $setup) {
    $setup($this);

    expect(issue(vtnPlan($this->request), 'unsupported_reference')?->level)->toBe(IssueLevel::Blocker);
})->with([
    'secret manager link' => [fn ($t) => Fixture::insert('secret_manager_links', ['uuid' => Fixture::uuid(), 'resourceable_type' => 'App\Models\Application', 'resourceable_id' => $t->web, 'integration_token_id' => integrationToken($t->a)])],
    'managed dns record' => [fn ($t) => Fixture::insert('managed_dns_record_references', ['managed_dns_record_id' => dnsRecord($t->a), 'resource_type' => 'App\Models\Application', 'resource_id' => $t->web])],
    'github runner' => [fn ($t) => Fixture::insert('github_runner_configs', ['uuid' => Fixture::uuid(), 'server_id' => $t->s1, 'github_app_id' => Fixture::githubApp($t->a, Fixture::privateKey($t->a)), 'labels' => '[]'])],
    'cloudflare tunnel token' => [fn ($t) => DB::table('server_settings')->where('server_id', $t->s1)->update(['cloudflare_tunnel_integration_token_id' => integrationToken($t->a)])],
]);

it('lists source api tokens as after-move actions', function () {
    Fixture::token($this->a, 'CI deploy');

    $issue = issue(vtnPlan($this->request), 'api_token');

    expect($issue->level)->toBe(IssueLevel::AfterMove)->and($issue->message)->toContain('CI deploy');
});

it('warns about active notification channels of the source', function () {
    Fixture::insert('discord_notification_settings', ['team_id' => $this->a, 'discord_enabled' => 'true']);

    expect(issue(vtnPlan($this->request), 'notifications')->level)->toBe(IssueLevel::Warning);
});

it('warns about project name clashes', function () {
    Fixture::project($this->b, 'P1');

    expect(issue(vtnPlan($this->request), 'project_name_clash')->message)->toContain('P1');
});

function integrationToken(int $teamId): int
{
    return Fixture::insert('integration_tokens', ['uuid' => Fixture::uuid(), 'team_id' => $teamId, 'provider' => 'cloudflare', 'name' => 'cf', 'token' => 't', 'capabilities' => '[]']);
}

function dnsRecord(int $teamId): int
{
    $token = integrationToken($teamId);
    $zone = Fixture::insert('dns_provider_zones', dnsZone($token));

    return Fixture::insert('managed_dns_records', ['uuid' => Fixture::uuid(), 'team_id' => $teamId, 'integration_token_id' => $token, 'dns_provider_zone_id' => $zone, 'provider_record_id' => 'r1', 'type' => 'A', 'name' => 'x', 'content' => '1.1.1.1']);
}

function dnsZone(int $tokenId): array
{
    return ['uuid' => Fixture::uuid(), 'integration_token_id' => $tokenId, 'provider_zone_id' => 'z1', 'name' => 'example.com'];
}
