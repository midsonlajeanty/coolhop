<?php

namespace App\Database;

use PDO;

final class ConnectionFactory
{
    public static function fromEnvironment(): PDO
    {
        $dsn = sprintf(
            'pgsql:host=%s;port=%s;dbname=%s',
            getenv('DB_HOST') ?: 'coolify-db',
            getenv('DB_PORT') ?: '5432',
            getenv('DB_DATABASE') ?: 'coolify',
        );

        return new PDO($dsn, getenv('DB_USERNAME') ?: 'coolify', getenv('DB_PASSWORD') ?: '', [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }
}
