<?php

declare(strict_types=1);

namespace App\Analysis;

final readonly class RowChange
{
    /**
     * @param  array<string, int|string>  $key
     */
    public function __construct(
        public string $table,
        public array $key,
        public string $column,
        public int|string|null $old,
        public int|string|CopyRef|null $new,
    ) {}
}
