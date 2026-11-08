<?php

namespace App\Analysis;

use App\Instance\Server;
use App\Instance\Team;

final readonly class MovePlan
{
    /**
     * @param  list<Server>  $servers
     * @param  list<RowChange>  $changes
     * @param  list<RowCopy>  $copies
     * @param  list<Issue>  $issues
     * @param  list<array{table: string, id: int, name: string}>  $unused
     */
    public function __construct(
        public Team $from,
        public Team $to,
        public array $servers,
        public array $changes,
        public array $copies,
        public array $issues,
        public array $unused,
    ) {}

    public function hasBlockers(): bool
    {
        return $this->issuesAt(IssueLevel::Blocker) !== [];
    }

    /**
     * @return list<Issue>
     */
    public function issuesAt(IssueLevel $level): array
    {
        return array_values(array_filter($this->issues, fn (Issue $issue) => $issue->level === $level));
    }

    public function fingerprint(): string
    {
        return hash('sha256', serialize([$this->changes, $this->copies]));
    }
}
