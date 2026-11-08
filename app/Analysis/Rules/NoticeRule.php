<?php

namespace App\Analysis\Rules;

use App\Analysis\IssueLevel;
use App\Analysis\PlanBuilder;
use App\Instance\Resource;

final class NoticeRule implements Rule
{
    private const NOTIFICATION_FLAGS = [
        'discord_notification_settings' => ['discord_enabled'],
        'email_notification_settings' => ['smtp_enabled', 'resend_enabled'],
        'pushover_notification_settings' => ['pushover_enabled'],
        'slack_notification_settings' => ['slack_enabled'],
        'telegram_notification_settings' => ['telegram_enabled'],
        'webhook_notification_settings' => ['webhook_enabled'],
    ];

    public function apply(PlanBuilder $plan): void
    {
        $this->unsupportedReferences($plan);
        $this->apiTokens($plan);
        $this->notifications($plan);
        $this->projectNameClashes($plan);
    }

    private function unsupportedReferences(PlanBuilder $plan): void
    {
        $found = [];

        foreach (collect($plan->movingResources())->groupBy(fn (Resource $r) => $r->morphClass()) as $morph => $resources) {
            $ids = $resources->pluck('id');
            if ($plan->db->table('secret_manager_links')->where('resourceable_type', $morph)->whereIn('resourceable_id', $ids)->exists()) {
                $found[] = 'secret manager links';
            }
            if ($plan->db->table('managed_dns_record_references')->where('resource_type', $morph)->whereIn('resource_id', $ids)->exists()) {
                $found[] = 'managed DNS records';
            }
        }

        if ($plan->db->table('github_runner_configs')->whereIn('server_id', $plan->serverIds())->exists()) {
            $found[] = 'GitHub runners';
        }
        if ($plan->db->table('server_settings')->whereIn('server_id', $plan->serverIds())->whereNotNull('cloudflare_tunnel_integration_token_id')->exists()) {
            $found[] = 'a Cloudflare tunnel integration';
        }

        foreach (array_unique($found) as $what) {
            $plan->issue(IssueLevel::Blocker, 'unsupported_reference', "Moving servers or resources use {$what}, which coolhop does not move yet.");
        }
    }

    private function apiTokens(PlanBuilder $plan): void
    {
        $names = $plan->db->table('personal_access_tokens')->where('team_id', (string) $plan->from->id)->orderBy('id')->pluck('name');

        if ($names->isNotEmpty()) {
            $plan->issue(IssueLevel::AfterMove, 'api_token', sprintf(
                'API tokens of %s (%s) cannot act on moved resources. Create tokens in %s and update the places that use them.',
                $plan->from->name, $names->implode(', '), $plan->to->name,
            ));
        }
    }

    private function notifications(PlanBuilder $plan): void
    {
        foreach (self::NOTIFICATION_FLAGS as $table => $flags) {
            $active = $plan->db->table($table)
                ->where('team_id', $plan->from->id)
                ->where(fn ($q) => collect($flags)->each(fn ($flag) => $q->orWhere($flag, true)))
                ->exists();

            if ($active) {
                $plan->issue(IssueLevel::Warning, 'notifications', sprintf(
                    '%s has notification channels. Moved servers will notify through the channels of %s.',
                    $plan->from->name, $plan->to->name,
                ));

                return;
            }
        }
    }

    private function projectNameClashes(PlanBuilder $plan): void
    {
        $moving = $plan->db->table('projects')->whereIn('id', collect($plan->movingResources())->pluck('projectId')->unique())->pluck('name');
        $clashes = $plan->db->table('projects')->where('team_id', $plan->to->id)->whereIn('name', $moving)->pluck('name');

        foreach ($clashes as $name) {
            $plan->issue(IssueLevel::Warning, 'project_name_clash', "{$plan->to->name} already has a project named \"{$name}\". Both will exist side by side.");
        }
    }
}
