<?php

namespace App\Analysis\Rules;

use App\Analysis\PlanBuilder;

interface Rule
{
    public function apply(PlanBuilder $plan): void;
}
