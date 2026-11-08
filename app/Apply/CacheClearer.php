<?php

declare(strict_types=1);

namespace App\Apply;

use Symfony\Component\Process\Process;

final readonly class CacheClearer
{
    public function __construct(private string $artisan = '/var/www/html/artisan') {}

    public function clear(): void
    {
        if (is_file($this->artisan)) {
            new Process(['php', $this->artisan, 'optimize:clear'])->run();
        }
    }
}
