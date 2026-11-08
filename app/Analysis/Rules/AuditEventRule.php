<?php

declare(strict_types=1);

namespace App\Analysis\Rules;

use App\Analysis\AuditTrail;
use App\Analysis\IssueLevel;
use App\Analysis\PlanBuilder;

final class AuditEventRule implements Rule
{
    public function apply(PlanBuilder $plan): void
    {
        $ids = new AuditTrail($plan->db)->eventIds($plan->from->id, $plan->movedIds());
        foreach ($ids as $id) {
            $plan->moveToTarget('audit_events', $id);
        }

        $left = $plan->db->table('audit_events')->where('team_id', $plan->from->id)->count() - count($ids);
        if ($left > 0) {
            $plan->issue(IssueLevel::Warning, 'audit_history_left', sprintf(
                '%d audit events stay in %s: they concern the team itself, its tags or items deleted since.',
                $left, $plan->from->name,
            ));
        }
    }
}
