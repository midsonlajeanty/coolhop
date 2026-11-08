<?php

use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\RowChange;
use App\Security\Decryptor;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

function movedEvents(MoveRequest $request): array
{
    $plan = new Planner(DB::connection(), new Decryptor(Fixture::APP_KEY))->plan($request);

    return collect($plan->changes)->where('table', 'audit_events')->map(fn (RowChange $c): int|string => $c->key['id'])->sort()->values()->all();
}

beforeEach(function (): void {
    $this->a = Fixture::team('A');
    $this->b = Fixture::team('B');
    $this->key = Fixture::privateKey($this->a);
    $this->s1 = Fixture::server($this->a, 'S1', $this->key);
    $this->s2 = Fixture::server($this->a, 'S2');
    $this->d1 = Fixture::destination($this->s1);
    $this->p1 = Fixture::project($this->a, 'P1');
    $this->e1 = Fixture::environment($this->p1);
    $this->web = Fixture::application($this->e1, $this->d1);
    $this->service = Fixture::service($this->e1, $this->d1);
    $this->request = new MoveRequest($this->a, $this->b, [$this->s1]);
});

it('moves the history of everything that moves', function (): void {
    $envVar = Fixture::envVar('App\Models\Application', $this->web, 'K', 'v');
    $deployment = Fixture::deployment($this->web, 'finished');
    $part = Fixture::insert('service_applications', ['uuid' => Fixture::uuid(), 'name' => 'web', 'service_id' => $this->service]);

    $expected = [
        Fixture::auditEvent($this->a, 'server', Fixture::uuidOf('servers', $this->s1)),
        Fixture::auditEvent($this->a, 'sentinel', Fixture::uuidOf('servers', $this->s1)),
        Fixture::auditEvent($this->a, 'destination', Fixture::uuidOf('standalone_dockers', $this->d1)),
        Fixture::auditEvent($this->a, 'project', Fixture::uuidOf('projects', $this->p1)),
        Fixture::auditEvent($this->a, 'environment', Fixture::uuidOf('environments', $this->e1)),
        Fixture::auditEvent($this->a, 'application', Fixture::uuidOf('applications', $this->web)),
        Fixture::auditEvent($this->a, 'service', Fixture::uuidOf('services', $this->service)),
        Fixture::auditEvent($this->a, 'service_application', Fixture::uuidOf('service_applications', $part)),
        Fixture::auditEvent($this->a, 'environment_variable', Fixture::uuidOf('environment_variables', $envVar)),
        Fixture::auditEvent($this->a, 'deployment', (string) DB::table('application_deployment_queues')->where('id', $deployment)->value('deployment_uuid')),
        Fixture::auditEvent($this->a, 'private_key', Fixture::uuidOf('private_keys', $this->key)),
    ];

    expect(movedEvents($this->request))->toBe($expected);
});

it('moves the history of soft deleted resources of moving projects', function (): void {
    $old = Fixture::application($this->e1, $this->d1);
    DB::table('applications')->where('id', $old)->update(['deleted_at' => now()]);
    $event = Fixture::auditEvent($this->a, 'application', Fixture::uuidOf('applications', $old));

    expect(movedEvents($this->request))->toBe([$event]);
});

it('keeps team level and unrelated history in the source team', function (): void {
    Fixture::auditEvent($this->a, 'team', null);
    Fixture::auditEvent($this->a, 'user', null);
    Fixture::auditEvent($this->a, 'api_token', null);
    Fixture::auditEvent($this->a, 'server', Fixture::uuidOf('servers', $this->s2));
    Fixture::auditEvent($this->a, 'application', 'deleted-long-ago');
    Fixture::auditEvent($this->b, 'server', Fixture::uuidOf('servers', $this->s1));

    expect(movedEvents($this->request))->toBe([]);
});

it('counts audit events in the plan', function (): void {
    Fixture::auditEvent($this->a, 'server', Fixture::uuidOf('servers', $this->s1));
    config()->set('coolhop.home', sys_get_temp_dir());
    putenv('APP_KEY='.Fixture::APP_KEY);

    $this->artisan('plan', ['--from' => 'A', '--to' => 'B', '--server' => ['S1']])
        ->expectsOutputToContain('1 audit events')
        ->assertExitCode(0);
});

it('says how much history stays behind', function (): void {
    Fixture::auditEvent($this->a, 'server', Fixture::uuidOf('servers', $this->s1));
    Fixture::auditEvent($this->a, 'team', null);
    Fixture::auditEvent($this->a, 'application', 'deleted-long-ago');

    $plan = new Planner(DB::connection(), new Decryptor(Fixture::APP_KEY))->plan($this->request);
    $issue = collect($plan->issues)->firstWhere('code', 'audit_history_left');

    expect($issue->message)->toContain('2 audit events stay in A');
});
