<?php

namespace App\Schema;

use PDO;

final class SchemaGuard
{
    public static function check(PDO $pdo): GuardResult
    {
        $lastMigration = (string) $pdo->query('select max(migration) from migrations')->fetchColumn();

        return new GuardResult(
            versionSupported: strcmp($lastMigration, KnownSchema::MIN_MIGRATION) >= 0,
            lastMigration: $lastMigration,
            unknownColumns: array_values(array_unique([...self::unknownTeamColumns($pdo), ...self::unknownForeignKeys($pdo)])),
        );
    }

    /**
     * @return list<string>
     */
    private static function unknownTeamColumns(PDO $pdo): array
    {
        $columns = $pdo->query(
            "select table_name || '.' || column_name from information_schema.columns
             where table_schema = 'public' and (column_name = 'team_id' or column_name like '%\\_team\\_id')
             order by 1"
        )->fetchAll(PDO::FETCH_COLUMN);

        return array_values(array_diff($columns, KnownSchema::OWNERSHIP_COLUMNS));
    }

    /**
     * @return list<string>
     */
    private static function unknownForeignKeys(PDO $pdo): array
    {
        $guarded = "'".implode("','", KnownSchema::GUARDED_TABLES)."'";
        $keys = $pdo->query(
            "select c.conrelid::regclass || '.' || a.attname || '->' || c.confrelid::regclass
             from pg_constraint c
             join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any(c.conkey)
             where c.contype = 'f' and c.confrelid::regclass::text in ({$guarded})
             order by 1"
        )->fetchAll(PDO::FETCH_COLUMN);

        $unknown = array_diff($keys, KnownSchema::FOREIGN_KEYS);

        return array_values(array_map(fn (string $key) => strstr($key, '->', true), $unknown));
    }
}
