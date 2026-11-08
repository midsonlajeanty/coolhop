<?php

namespace App\Analysis;

final readonly class RowCopy
{
    /**
     * @param  array<string, int|string|null>  $overrides
     */
    public function __construct(
        public string $ref,
        public string $table,
        public int $sourceId,
        public array $overrides,
    ) {}
}
