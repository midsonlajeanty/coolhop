<?php

namespace App\Instance;

final readonly class Resource
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
        return \App\Schema\KnownSchema::RESOURCE_TABLES[$this->table];
    }
}
