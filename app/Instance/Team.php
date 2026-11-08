<?php

declare(strict_types=1);

namespace App\Instance;

final readonly class Team
{
    public function __construct(public int $id, public string $name) {}
}
