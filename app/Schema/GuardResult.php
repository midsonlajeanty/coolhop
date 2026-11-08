<?php

namespace App\Schema;

final readonly class GuardResult
{
    /**
     * @param  list<string>  $unknownColumns
     */
    public function __construct(
        public bool $versionSupported,
        public string $lastMigration,
        public array $unknownColumns,
    ) {}

    public function canApply(): bool
    {
        return $this->versionSupported && $this->unknownColumns === [];
    }
}
