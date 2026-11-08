<?php

declare(strict_types=1);

namespace App\Instance;

final readonly class Server
{
    public function __construct(
        public int $id,
        public string $uuid,
        public string $name,
        public string $ip,
        public int $teamId,
        public ?int $privateKeyId,
        public ?int $cloudProviderTokenId,
        public bool $isBuildServer,
        public bool $isSwarmManager,
        public bool $isSwarmWorker,
    ) {}
}
