<?php

declare(strict_types=1);

namespace App\Analysis;

enum TeamVariablePolicy: string
{
    case KeepTarget = 'keep';
    case Stop = 'stop';
}
