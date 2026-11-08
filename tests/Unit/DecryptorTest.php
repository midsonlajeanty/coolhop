<?php

use App\Analysis\MovePlan;
use App\Analysis\RowChange;
use App\Instance\Team;
use App\Security\Decryptor;
use Illuminate\Encryption\Encrypter;
use Tests\Support\Fixture;

it('decrypts values encrypted with the app key', function (): void {
    $decryptor = new Decryptor(Fixture::APP_KEY);

    expect($decryptor->decrypt(Fixture::encrypt('{{team.FLUX}}')))->toBe('{{team.FLUX}}');
});

it('decrypts serialized values', function (): void {
    $encrypter = new Encrypter(base64_decode(substr(Fixture::APP_KEY, 7)), 'aes-256-cbc');

    expect(new Decryptor(Fixture::APP_KEY)->decrypt($encrypter->encrypt('plain')))->toBe('plain');
});

it('returns null for garbage', function (): void {
    expect(new Decryptor(Fixture::APP_KEY)->decrypt('not-a-payload'))->toBeNull();
});

it('fingerprints plans independently of row order', function () {
    $team = new Team(1, 'A');
    $one = new RowChange('servers', ['id' => 1], 'team_id', 1, 2);
    $two = new RowChange('servers', ['id' => 2], 'team_id', 1, 2);
    $plan = fn (array $changes) => new MovePlan($team, $team, [], $changes, [], [], []);

    expect($plan([$one, $two])->fingerprint())->toBe($plan([$two, $one])->fingerprint());
});
