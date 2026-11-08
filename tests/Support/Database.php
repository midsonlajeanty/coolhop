<?php

namespace Tests\Support;

use PDO;

final class Database
{
    private const string DEFAULT_URL = 'pgsql:host=127.0.0.1;port=54329;dbname=coolify;user=postgres;password=x';

    private static ?PDO $pdo = null;

    private static ?string $truncate = null;

    public static function pdo(): PDO
    {
        if (! self::$pdo instanceof PDO) {
            self::$pdo = new PDO(getenv('COOLHOP_TEST_DB_URL') ?: self::DEFAULT_URL, options: [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
            self::loadSchemaIfMissing(self::$pdo);
        }

        return self::$pdo;
    }

    public static function reset(): void
    {
        $pdo = self::pdo();
        self::$truncate ??= self::truncateStatement($pdo);
        $pdo->exec(self::$truncate);
    }

    private static function loadSchemaIfMissing(PDO $pdo): void
    {
        $exists = $pdo->query("select to_regclass('public.migrations') is not null")->fetchColumn();

        if (! $exists) {
            $pdo->exec(file_get_contents(__DIR__.'/../fixtures/schema.sql'));
            $pdo->exec('set search_path to public');
        }
    }

    private static function truncateStatement(PDO $pdo): string
    {
        $tables = $pdo->query(
            "select quote_ident(tablename) from pg_tables where schemaname = 'public' and tablename <> 'migrations'"
        )->fetchAll(PDO::FETCH_COLUMN);

        return 'truncate '.implode(', ', $tables).' restart identity cascade';
    }
}
