<?php

declare(strict_types=1);

namespace App\Apply;

final readonly class CacheClearer
{
    public function __construct(private string $artisan = '/var/www/html/artisan') {}

    public function clear(): void
    {
        if (is_file($this->artisan)) {
            exec(sprintf('php %s optimize:clear 2>&1', escapeshellarg($this->artisan)));
        }
    }
}
