<?php

namespace App\Analysis;

enum TeamVariablePolicy: string
{
    case KeepTarget = 'keep';
    case Stop = 'stop';
}
