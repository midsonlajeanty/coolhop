<?php

namespace App\Analysis\Rules;

use App\Analysis\PlanBuilder;

final class TagRule implements Rule
{
    public function apply(PlanBuilder $plan): void
    {
        $targetTags = $plan->db->table('tags')->where('team_id', $plan->to->id)->pluck('id', 'name');

        foreach ($plan->movingMorphs() as $morph => $ids) {
            $plan->db->table('taggables as tg')
                ->join('tags as t', 't.id', '=', 'tg.tag_id')
                ->where('t.team_id', $plan->from->id)
                ->where('tg.taggable_type', $morph)
                ->whereIn('tg.taggable_id', $ids)
                ->orderBy('tg.taggable_id')->orderBy('t.id')
                ->get(['tg.tag_id', 'tg.taggable_id', 'tg.taggable_type', 't.name'])
                ->each(function ($row) use ($plan, $targetTags): void {
                    $new = $targetTags->has($row->name) ? (int) $targetTags[$row->name] : $plan->copy('tags', (int) $row->tag_id);
                    $plan->change(
                        'taggables',
                        ['tag_id' => (int) $row->tag_id, 'taggable_id' => (int) $row->taggable_id, 'taggable_type' => $row->taggable_type],
                        'tag_id',
                        (int) $row->tag_id,
                        $new,
                    );
                });
        }
    }
}
