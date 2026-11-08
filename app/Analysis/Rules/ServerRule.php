<?php

namespace App\Analysis\Rules;

use App\Analysis\PlanBuilder;

final class ServerRule implements Rule
{
    public function apply(PlanBuilder $plan): void
    {
        foreach ($plan->serverIds() as $serverId) {
            $plan->moveToTarget('servers', $serverId);
        }
    }
}
