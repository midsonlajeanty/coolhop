<?php

namespace App\Analysis\Rules;

use App\Analysis\IssueLevel;
use App\Analysis\PlanBuilder;
use App\Analysis\TeamVariablePolicy;

final class SharedVariableRule implements Rule
{
    private const string TEAM_REFERENCE = '/\{\{\s*team\.([A-Za-z0-9_]+)\s*\}\}/';

    public function apply(PlanBuilder $plan): void
    {
        $this->moveScopedVariables($plan);
        $this->copyReferencedTeamVariables($plan);
    }

    private function moveScopedVariables(PlanBuilder $plan): void
    {
        $projects = collect($plan->movingResources())->pluck('projectId')->unique()->values();
        $environments = $plan->db->table('environments')->whereIn('project_id', $projects)->pluck('id');

        $plan->db->table('shared_environment_variables')
            ->where('team_id', $plan->from->id)
            ->where(fn ($q) => $q
                ->where(fn ($q) => $q->where('type', 'server')->whereIn('server_id', $plan->serverIds()))
                ->orWhere(fn ($q) => $q->where('type', 'project')->whereIn('project_id', $projects))
                ->orWhere(fn ($q) => $q->where('type', 'environment')->whereIn('environment_id', $environments)))
            ->orderBy('id')
            ->pluck('id')
            ->each(fn ($id) => $plan->moveToTarget('shared_environment_variables', (int) $id));
    }

    private function copyReferencedTeamVariables(PlanBuilder $plan): void
    {
        $referenced = $this->referencedKeys($plan);
        if ($referenced === []) {
            return;
        }

        $teamVariables = fn (int $teamId) => $plan->db->table('shared_environment_variables')
            ->where('team_id', $teamId)->where('type', 'team')->whereIn('key', $referenced)
            ->pluck('id', 'key');

        $source = $teamVariables($plan->from->id);
        $target = $teamVariables($plan->to->id);

        foreach ($referenced as $key) {
            if ($target->has($key)) {
                $stop = $plan->request->teamVariablePolicy === TeamVariablePolicy::Stop;
                $plan->issue($stop ? IssueLevel::Blocker : IssueLevel::Warning, 'team_variable_clash', sprintf(
                    'Team variable %s exists in both teams. Moved resources will use the value from %s.',
                    $key, $plan->to->name,
                ));

                continue;
            }

            if ($source->has($key)) {
                $plan->copy('shared_environment_variables', (int) $source[$key]);

                continue;
            }

            $plan->issue(IssueLevel::Warning, 'missing_team_variable', "Team variable {$key} is referenced but defined in neither team.");
        }
    }

    /**
     * @return list<string>
     */
    private function referencedKeys(PlanBuilder $plan): array
    {
        if (! $plan->decryptor->canDecrypt()) {
            $plan->issue(IssueLevel::Warning, 'team_variables_unchecked', 'APP_KEY is not available, so references to team variables could not be checked.');

            return [];
        }

        $keys = [];
        $undecryptable = 0;
        foreach ($plan->movingMorphs() as $morph => $ids) {
            $payloads = $plan->db->table('environment_variables')
                ->where('resourceable_type', $morph)
                ->whereIn('resourceable_id', $ids)
                ->whereNotNull('value')
                ->pluck('value');

            foreach ($payloads as $payload) {
                $value = $plan->decryptor->decrypt((string) $payload);
                if ($value === null) {
                    $undecryptable++;

                    continue;
                }
                preg_match_all(self::TEAM_REFERENCE, $value, $matches);
                array_push($keys, ...$matches[1]);
            }
        }

        if ($undecryptable > 0) {
            $plan->issue(IssueLevel::Warning, 'undecryptable_values', sprintf(
                '%d environment variable values of moving resources could not be decrypted with APP_KEY, so their {{team.X}} references were not checked.',
                $undecryptable,
            ));
        }

        $keys = array_values(array_unique($keys));
        sort($keys);

        return $keys;
    }
}
