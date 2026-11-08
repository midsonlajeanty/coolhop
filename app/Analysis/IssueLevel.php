<?php

namespace App\Analysis;

enum IssueLevel: string
{
    case Blocker = 'blocker';
    case Warning = 'warning';
    case AfterMove = 'after_move';
}
