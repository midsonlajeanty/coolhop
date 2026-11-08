<?php

namespace App\Analysis\Rules;

use App\Analysis\PlanBuilder;
use App\Analysis\References;

final class UnusedItemRule implements Rule
{
    public function apply(PlanBuilder $plan): void
    {
        $taken = array_flip($plan->request->takeUnused);
        $keysOfUnusedGitApps = [];

        foreach (array_keys(References::SHARED) as $itemTable) {
            $items = $plan->db->table($itemTable)->where('team_id', $plan->from->id)->orderBy('id')->get();

            foreach ($items as $item) {
                if (isset($taken["{$itemTable}:{$item->id}"]) || $this->isReferenced($plan, $itemTable, (int) $item->id, $keysOfUnusedGitApps)) {
                    continue;
                }

                if (isset(References::GIT_APPS[$itemTable]) && $item->private_key_id !== null) {
                    $keysOfUnusedGitApps[] = (int) $item->private_key_id;
                }

                $plan->unused($itemTable, (int) $item->id, $item->name ?? "#{$item->id}");
            }
        }
    }

    /**
     * @param  list<int>  $ignoredKeys
     */
    private function isReferenced(PlanBuilder $plan, string $itemTable, int $id, array $ignoredKeys): bool
    {
        if ($itemTable === 'private_keys' && in_array($id, $ignoredKeys, true)) {
            return true;
        }

        foreach (References::SHARED[$itemTable] as $reference) {
            [$table, $column] = $reference;
            $used = $plan->db->table($table)
                ->where($column, $id)
                ->when(isset($reference[2]), fn ($q) => $q->where($reference[2], $reference[3]))
                ->exists();

            if ($used) {
                return true;
            }
        }

        return false;
    }
}
