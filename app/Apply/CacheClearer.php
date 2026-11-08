<?php

namespace App\Apply;

final class CacheClearer
{
    public function __construct(private readonly string $artisan = '/var/www/html/artisan') {}

    public function clear(): void
    {
        if (is_file($this->artisan)) {
            exec(sprintf('php %s optimize:clear 2>&1', escapeshellarg($this->artisan)));
        }
    }
}
