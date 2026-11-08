<?php

namespace App\Analysis\Rules;

use App\Analysis\IssueLevel;
use App\Analysis\PlanBuilder;
use App\Instance\Resource;

final class TopologyRule implements Rule
{
    private const ACTIVE_DEPLOYMENT_STATUSES = ['queued', 'in_progress'];

    public function apply(PlanBuilder $plan): void
    {
        $this->additionalDestinations($plan);
        $this->buildServers($plan);
        $this->swarm($plan);
        $this->activeDeployments($plan);
    }

    private function additionalDestinations(PlanBuilder $plan): void
    {
        $movingApps = $this->ids($plan->movingResources('applications'));
        $sourceApps = $this->ids(array_filter($plan->sourceResources, fn (Resource $r) => $r->table === 'applications'));

        $plan->db->table('additional_destinations as ad')
            ->join('applications as a', 'a.id', '=', 'ad.application_id')
            ->whereIn('ad.application_id', $sourceApps)
            ->get(['ad.application_id', 'ad.server_id', 'a.name'])
            ->each(function ($row) use ($plan, $movingApps) {
                $appMoves = in_array((int) $row->application_id, $movingApps, true);
                if ($appMoves !== $plan->isMovingServer((int) $row->server_id)) {
                    $plan->issue(IssueLevel::Blocker, 'split_destinations', sprintf(
                        'Application "%s" also deploys to %s, which ends up in the other team.',
                        $row->name, $plan->serverName((int) $row->server_id),
                    ));
                }
            });
    }

    private function buildServers(PlanBuilder $plan): void
    {
        $usesBuildServer = fn (array $apps) => $plan->db->table('application_settings')
            ->whereIn('application_id', $this->ids($apps))
            ->where('is_build_server_enabled', true)
            ->exists();

        $movingBuilders = array_filter($plan->servers, fn ($s) => $s->isBuildServer);
        $stayingBuilders = array_filter(
            $plan->inventory->servers($plan->from->id),
            fn ($s) => $s->isBuildServer && ! $plan->isMovingServer($s->id),
        );
        $targetBuilders = array_filter($plan->inventory->servers($plan->to->id), fn ($s) => $s->isBuildServer);

        if ($movingBuilders !== [] && $stayingBuilders === [] && $usesBuildServer($plan->stayingResources('applications'))) {
            $plan->issue(IssueLevel::Blocker, 'build_server', sprintf(
                'Applications staying in %s build on %s, which would leave the team.',
                $plan->from->name, implode(', ', array_map(fn ($s) => $s->name, $movingBuilders)),
            ));
        }

        if ($movingBuilders === [] && $targetBuilders === [] && $usesBuildServer($plan->movingResources('applications'))) {
            $plan->issue(IssueLevel::Blocker, 'build_server', sprintf(
                'Moving applications use a build server, and %s has none.',
                $plan->to->name,
            ));
        }
    }

    private function swarm(PlanBuilder $plan): void
    {
        $isSwarm = fn ($s) => $s->isSwarmManager || $s->isSwarmWorker;
        if (! array_filter($plan->servers, $isSwarm)) {
            return;
        }

        $left = array_filter(
            $plan->inventory->servers($plan->from->id),
            fn ($s) => $isSwarm($s) && ! $plan->isMovingServer($s->id),
        );

        if ($left !== []) {
            $plan->issue(IssueLevel::Blocker, 'split_swarm', sprintf(
                'Swarm servers must move together. Not selected: %s.',
                implode(', ', array_map(fn ($s) => $s->name, $left)),
            ));
        }
    }

    private function activeDeployments(PlanBuilder $plan): void
    {
        $apps = array_map('strval', $this->ids($plan->movingResources('applications')));
        $active = $plan->db->table('application_deployment_queues')
            ->whereIn('application_id', $apps)
            ->whereIn('status', self::ACTIVE_DEPLOYMENT_STATUSES)
            ->pluck('application_name')
            ->unique();

        if ($active->isNotEmpty()) {
            $plan->issue(IssueLevel::Blocker, 'active_deployment', sprintf(
                'Deployments are queued or running for: %s. Wait for them to finish.',
                $active->map(fn ($n) => $n ?? 'an application')->implode(', '),
            ));
        }
    }

    /**
     * @param  array<Resource>  $resources
     * @return list<int>
     */
    private function ids(array $resources): array
    {
        return array_values(array_map(fn (Resource $r) => $r->id, $resources));
    }
}
