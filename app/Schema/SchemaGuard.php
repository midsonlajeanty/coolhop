<?php

namespace App\Schema;

use Illuminate\Database\ConnectionInterface;

final class SchemaGuard
{
    public static function check(ConnectionInterface $db): GuardResult
    {
        $lastMigration = (string) $db->table('migrations')->max('migration');

        return new GuardResult(
            versionSupported: strcmp($lastMigration, KnownSchema::MIN_MIGRATION) >= 0,
            lastMigration: $lastMigration,
            unknownColumns: array_values(array_unique([...self::unknownTeamColumns($db), ...self::unknownForeignKeys($db), ...self::unknownReferenceColumns($db)])),
        );
    }

    /**
     * @return list<string>
     */
    private static function unknownTeamColumns(ConnectionInterface $db): array
    {
        $columns = $db->table('information_schema.columns')
            ->where('table_schema', 'public')
            ->where(fn ($q) => $q->where('column_name', 'team_id')->orWhere('column_name', 'like', '%\_team\_id'))
            ->orderBy('table_name')->orderBy('column_name')
            ->get(['table_name', 'column_name'])
            ->map(fn ($row): string => "{$row->table_name}.{$row->column_name}")
            ->all();

        return array_values(array_diff($columns, KnownSchema::OWNERSHIP_COLUMNS));
    }

    /**
     * @return list<string>
     */
    private static function unknownForeignKeys(ConnectionInterface $db): array
    {
        $keys = collect($db->select(
            "select c.conrelid::regclass::text as source, a.attname as column_name, c.confrelid::regclass::text as target
             from pg_constraint c
             join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any(c.conkey)
             where c.contype = 'f'"
        ))
            ->whereIn('target', KnownSchema::GUARDED_TABLES)
            ->reject(fn ($key): bool => in_array("{$key->source}.{$key->column_name}->{$key->target}", KnownSchema::FOREIGN_KEYS, true))
            ->map(fn ($key): string => "{$key->source}.{$key->column_name}");

        return array_values($keys->all());
    }

    /**
     * @return list<string>
     */
    private static function unknownReferenceColumns(ConnectionInterface $db): array
    {
        $columns = $db->table('information_schema.columns')
            ->where('table_schema', 'public')
            ->where(fn ($q) => $q->where('column_name', 'like', '%\_id')->orWhere('column_name', 'like', '%\_type'))
            ->orderBy('table_name')->orderBy('column_name')
            ->get(['table_name', 'column_name'])
            ->map(fn ($row): string => $row->table_name.'.'.$row->column_name)
            ->all();

        return array_values(array_diff($columns, ReferenceColumns::ALL));
    }
}
