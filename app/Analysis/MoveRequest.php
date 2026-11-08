<?php

namespace App\Analysis;

final readonly class MoveRequest
{
    /**
     * @param  list<int>  $serverIds
     * @param  list<string>  $takeUnused  items as "table:id"
     */
    public function __construct(
        public int $fromTeamId,
        public int $toTeamId,
        public array $serverIds,
        public array $takeUnused = [],
        public TeamVariablePolicy $teamVariablePolicy = TeamVariablePolicy::KeepTarget,
    ) {}

    public function toArray(): array
    {
        return [
            'from' => $this->fromTeamId,
            'to' => $this->toTeamId,
            'servers' => $this->serverIds,
            'take_unused' => $this->takeUnused,
            'team_variable_policy' => $this->teamVariablePolicy->value,
        ];
    }

    public static function fromArray(array $data): self
    {
        return new self(
            $data['from'],
            $data['to'],
            $data['servers'],
            $data['take_unused'] ?? [],
            TeamVariablePolicy::from($data['team_variable_policy'] ?? 'keep'),
        );
    }
}
