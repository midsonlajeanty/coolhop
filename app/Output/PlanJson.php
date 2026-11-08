<?php

namespace App\Output;

use App\Analysis\CopyRef;
use App\Analysis\MovePlan;
use App\Schema\GuardResult;

final class PlanJson
{
    public static function from(MovePlan $plan, GuardResult $guard): array
    {
        return [
            'from' => ['id' => $plan->from->id, 'name' => $plan->from->name],
            'to' => ['id' => $plan->to->id, 'name' => $plan->to->name],
            'servers' => array_map(fn ($s) => ['id' => $s->id, 'uuid' => $s->uuid, 'name' => $s->name], $plan->servers),
            'changes' => array_map(fn ($c) => [
                'table' => $c->table,
                'key' => $c->key,
                'column' => $c->column,
                'old' => $c->old,
                'new' => $c->new instanceof CopyRef ? ['copy' => $c->new->ref] : $c->new,
            ], $plan->changes),
            'copies' => array_map(fn ($c) => ['ref' => $c->ref, 'table' => $c->table, 'source_id' => $c->sourceId], $plan->copies),
            'issues' => array_map(fn ($i) => ['level' => $i->level->value, 'code' => $i->code, 'message' => $i->message], $plan->issues),
            'unused' => $plan->unused,
            'schema' => ['last_migration' => $guard->lastMigration, 'can_apply' => $guard->canApply(), 'unknown_columns' => $guard->unknownColumns],
            'fingerprint' => $plan->fingerprint(),
        ];
    }
}
