<?php

declare(strict_types=1);

namespace App\Analysis;

final readonly class CopyRef
{
    public function __construct(public string $ref) {}
}
