<?php

declare(strict_types=1);

namespace App\Output;

use App\Analysis\CopyRef;
use App\Analysis\Issue;
use App\Analysis\MovePlan;
use App\Analysis\RowChange;
use App\Analysis\RowCopy;
use App\Instance\Server;
use App\Schema\GuardResult;

final class PlanJson
{
    /**
     * @return array<string, mixed>
     */
    public static function from(MovePlan $plan, GuardResult $guard): array
    {
        return [
            'from' => ['id' => $plan->from->id, 'name' => $plan->from->name],
            'to' => ['id' => $plan->to->id, 'name' => $plan->to->name],
            'servers' => array_map(fn (Server $s): array => ['id' => $s->id, 'uuid' => $s->uuid, 'name' => $s->name], $plan->servers),
            'changes' => array_map(fn (RowChange $c): array => [
                'table' => $c->table,
                'key' => $c->key,
                'column' => $c->column,
                'old' => $c->old,
                'new' => $c->new instanceof CopyRef ? ['copy' => $c->new->ref] : $c->new,
            ], $plan->changes),
            'copies' => array_map(fn (RowCopy $c): array => ['ref' => $c->ref, 'table' => $c->table, 'source_id' => $c->sourceId], $plan->copies),
            'issues' => array_map(fn (Issue $i): array => ['level' => $i->level->value, 'code' => $i->code, 'message' => $i->message], $plan->issues),
            'unused' => $plan->unused,
            'schema' => ['last_migration' => $guard->lastMigration, 'can_apply' => $guard->canApply(), 'unknown_columns' => $guard->unknownColumns],
            'fingerprint' => $plan->fingerprint(),
        ];
    }
}
