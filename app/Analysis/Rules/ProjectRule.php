<?php

namespace App\Analysis\Rules;

use App\Analysis\IssueLevel;
use App\Analysis\PlanBuilder;
use App\Instance\Resource;

final class ProjectRule implements Rule
{
    public function apply(PlanBuilder $plan): void
    {
        foreach ($plan->sourceResources as $resource) {
            if ($resource->unknownDestinationType !== null) {
                $plan->issue(IssueLevel::Blocker, 'unknown_destination', sprintf(
                    '%s "%s" (%s) uses the destination type %s, which coolhop does not know.',
                    $resource->table, $resource->name, $resource->id, $resource->unknownDestinationType,
                ));
            }
        }

        collect($plan->sourceResources)
            ->groupBy('projectId')
            ->each(function ($resources, int $projectId) use ($plan) {
                $this->classify($plan, $projectId, $resources->all());
            });
    }

    /**
     * @param  list<Resource>  $resources
     */
    private function classify(PlanBuilder $plan, int $projectId, array $resources): void
    {
        $moving = array_filter($resources, fn (Resource $r) => $r->serverId !== null && $plan->isMovingServer($r->serverId));
        if ($moving === []) {
            return;
        }

        $staying = array_filter($resources, fn (Resource $r) => $r->serverId === null || ! $plan->isMovingServer($r->serverId));
        if ($staying === []) {
            $plan->moveProject($projectId);

            return;
        }

        $name = $plan->db->table('projects')->where('id', $projectId)->value('name');
        $servers = fn (array $list) => collect($list)->map(fn (Resource $r) => $plan->serverName($r->serverId))->unique()->implode(', ');

        $plan->issue(IssueLevel::Blocker, 'mixed_project', sprintf(
            'Project "%s" has resources on moving servers (%s) and on servers that stay (%s).',
            $name, $servers($moving), $servers($staying),
        ));
    }
}
