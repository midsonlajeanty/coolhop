<?php

declare(strict_types=1);

namespace App\Instance;

use App\Schema\KnownSchema;

final readonly class HostedResource
{
    public function __construct(
        public string $table,
        public int $id,
        public string $name,
        public int $environmentId,
        public int $projectId,
        public int $teamId,
        public ?int $serverId,
        public ?string $unknownDestinationType,
    ) {}

    public function morphClass(): string
    {
        return KnownSchema::RESOURCE_TABLES[$this->table];
    }
}
