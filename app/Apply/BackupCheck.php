<?php

namespace App\Apply;

use RuntimeException;

final class BackupCheck
{
    public const MAX_AGE_SECONDS = 3600;

    public static function assertFresh(?string $path, int $maxAgeSeconds = self::MAX_AGE_SECONDS): void
    {
        clearstatcache();

        if ($path === null || $path === '' || ! is_file($path) || filesize($path) === 0) {
            throw new RuntimeException('Backup missing: run coolhop through install.sh, which backs up the Coolify database first.');
        }

        if (time() - filemtime($path) > $maxAgeSeconds) {
            throw new RuntimeException('Backup older than one hour: run coolhop again through install.sh to take a fresh one.');
        }
    }
}
