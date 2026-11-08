<?php

namespace App\Apply;

use RuntimeException;

final class Journal
{
    /**
     * @param  list<array{table: string, key: array<string, int|string>, column: string, old: int|string|null, new: int|string|null}>  $changes
     * @param  list<array{table: string, id: int, ref: string}>  $created
     */
    public function __construct(
        public readonly string $id,
        public readonly string $createdAt,
        public readonly array $request,
        public readonly array $changes,
        public readonly array $created,
        public readonly string $backupPath,
        public ?string $rolledBackAt = null,
    ) {}

    public static function newId(): string
    {
        return gmdate('Ymd-His').'-'.bin2hex(random_bytes(2));
    }

    public static function path(string $home, string $id): string
    {
        return "{$home}/{$id}/journal.json";
    }

    public static function fromFile(string $path): self
    {
        if (! is_file($path)) {
            throw new RuntimeException("Journal not found: {$path}");
        }

        $data = json_decode((string) file_get_contents($path), true, flags: JSON_THROW_ON_ERROR);

        return new self(
            $data['id'],
            $data['created_at'],
            $data['request'],
            $data['changes'],
            $data['created'],
            $data['backup_path'],
            $data['rolled_back_at'] ?? null,
        );
    }

    public function toJson(): string
    {
        return json_encode([
            'id' => $this->id,
            'created_at' => $this->createdAt,
            'request' => $this->request,
            'changes' => $this->changes,
            'created' => $this->created,
            'backup_path' => $this->backupPath,
            'rolled_back_at' => $this->rolledBackAt,
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR)."\n";
    }

    public function save(string $home): string
    {
        $path = self::path($home, $this->id);
        if (! is_dir(dirname($path)) && ! mkdir(dirname($path), 0700, true)) {
            throw new RuntimeException("Cannot create {$path}");
        }
        file_put_contents($path, $this->toJson());

        return $path;
    }
}
