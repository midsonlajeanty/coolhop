<?php

declare(strict_types=1);

namespace App\Analysis;

use Illuminate\Database\ConnectionInterface;
use Illuminate\Database\Query\Builder;

final readonly class Reference
{
    public function __construct(
        public string $table,
        public string $column,
        public ?string $typeColumn = null,
        public ?string $type = null,
    ) {}

    /**
     * @param  iterable<int|string>|int  $ids
     */
    public function query(ConnectionInterface $db, iterable|int $ids): Builder
    {
        $query = $db->table($this->table);
        is_int($ids) ? $query->where($this->column, $ids) : $query->whereIn($this->column, $ids);

        if ($this->typeColumn !== null) {
            $query->where($this->typeColumn, $this->type);
        }

        return $query;
    }
}
