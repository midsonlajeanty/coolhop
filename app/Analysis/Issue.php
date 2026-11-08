<?php

namespace App\Analysis;

final readonly class Issue
{
    public function __construct(
        public IssueLevel $level,
        public string $code,
        public string $message,
    ) {}
}
