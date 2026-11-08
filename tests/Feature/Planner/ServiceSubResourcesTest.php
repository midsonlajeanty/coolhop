<?php

use App\Analysis\IssueLevel;
use App\Analysis\MovePlan;
use App\Analysis\MoveRequest;
use App\Analysis\Planner;
use App\Analysis\RowChange;
use App\Security\Decryptor;
use Illuminate\Support\Facades\DB;
use Tests\Support\Fixture;

function subPlan(MoveRequest $request): MovePlan
{
    return new Planner(DB::connection(), new Decryptor(Fixture::APP_KEY))->plan($request);
}

beforeEach(function (): void {
    $this->a = Fixture::team('A');
    $this->b = Fixture::team('B');
    $this->s1 = Fixture::server($this->a, 'S1');
    $d1 = Fixture::destination($this->s1);
    $this->service = Fixture::service(Fixture::environment(Fixture::project($this->a, 'P')), $d1);
    $this->serviceDb = Fixture::insert('service_databases', ['uuid' => Fixture::uuid(), 'name' => 'postgres', 'service_id' => $this->service]);
    $this->serviceApp = Fixture::insert('service_applications', ['uuid' => Fixture::uuid(), 'name' => 'web', 'service_id' => $this->service]);
    $this->request = new MoveRequest($this->a, $this->b, [$this->s1]);
});

it('moves backups of databases inside moving services, with their storage', function (): void {
    $s3 = Fixture::s3($this->a);
    $backup = Fixture::insert('scheduled_database_backups', ['uuid' => Fixture::uuid(), 'team_id' => $this->a, 'frequency' => '0 0 * * *', 'database_type' => 'App\Models\ServiceDatabase', 'database_id' => $this->serviceDb, 's3_storage_id' => $s3]);

    $moved = collect(subPlan($this->request)->changes)->filter(fn (RowChange $c): bool => $c->column === 'team_id')->map(fn (RowChange $c): string => "{$c->table}:{$c->key['id']}")->all();

    expect($moved)->toContain("scheduled_database_backups:{$backup}", "s3_storages:{$s3}");
});

it('moves volume backups of service applications', function (): void {
    $volume = Fixture::insert('scheduled_volume_backups', ['uuid' => Fixture::uuid(), 'backupable_type' => 'App\Models\ServiceApplication', 'backupable_id' => $this->serviceApp, 'team_id' => $this->a, 'frequency' => '0 0 * * *']);

    $moved = collect(subPlan($this->request)->changes)->where('table', 'scheduled_volume_backups')->map(fn (RowChange $c): int|string => $c->key['id'])->values()->all();

    expect($moved)->toBe([$volume]);
});

it('blocks unsupported references on service sub resources', function (): void {
    $token = Fixture::insert('integration_tokens', ['uuid' => Fixture::uuid(), 'team_id' => $this->a, 'provider' => 'x', 'name' => 'x', 'token' => 't', 'capabilities' => '[]']);
    Fixture::insert('secret_manager_links', ['uuid' => Fixture::uuid(), 'resourceable_type' => 'App\Models\ServiceApplication', 'resourceable_id' => $this->serviceApp, 'integration_token_id' => $token]);

    expect(collect(subPlan($this->request)->issues)->firstWhere('code', 'unsupported_reference')?->level)->toBe(IssueLevel::Blocker);
});

it('copies a storage that the team avatar still uses', function (): void {
    $s3 = Fixture::s3($this->a);
    DB::table('teams')->where('id', $this->a)->update(['avatar_s3_storage_id' => $s3]);
    Fixture::insert('scheduled_database_backups', ['uuid' => Fixture::uuid(), 'team_id' => $this->a, 'frequency' => '0 0 * * *', 'database_type' => 'App\Models\ServiceDatabase', 'database_id' => $this->serviceDb, 's3_storage_id' => $s3]);

    $plan = subPlan($this->request);

    expect(collect($plan->copies)->pluck('ref')->all())->toBe(["s3_storages:{$s3}"]);
});

it('does not offer a storage used by the team avatar as unused', function (): void {
    $s3 = Fixture::s3($this->a, 'avatars');
    DB::table('teams')->where('id', $this->a)->update(['avatar_s3_storage_id' => $s3]);

    expect(collect(subPlan($this->request)->unused)->pluck('name')->all())->not->toContain('avatars');
});

it('warns when values cannot be decrypted', function (): void {
    $app = Fixture::application(Fixture::environment(Fixture::project($this->a, 'Q')), Fixture::destination($this->s1));
    Fixture::insert('environment_variables', ['uuid' => Fixture::uuid(), 'key' => 'K', 'value' => 'eyJnYXJiYWdlIjp0cnVlfQ==', 'resourceable_type' => 'App\Models\Application', 'resourceable_id' => $app]);

    $issue = collect(subPlan($this->request)->issues)->firstWhere('code', 'undecryptable_values');

    expect($issue?->level)->toBe(IssueLevel::Warning);
});
