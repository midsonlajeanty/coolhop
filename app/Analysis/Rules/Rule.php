<?php

declare(strict_types=1);

namespace App\Analysis\Rules;

use App\Analysis\PlanBuilder;

interface Rule
{
    public function apply(PlanBuilder $plan): void;
}
