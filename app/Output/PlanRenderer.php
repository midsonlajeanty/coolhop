<?php

namespace App\Output;

use App\Analysis\CopyRef;
use App\Analysis\IssueLevel;
use App\Analysis\MovePlan;
use App\Analysis\RowChange;
use App\Schema\GuardResult;
use Illuminate\Console\OutputStyle;
use Illuminate\Database\ConnectionInterface;

final class PlanRenderer
{
    private const LABELS = [
        'servers' => 'servers',
        'projects' => 'projects',
        'private_keys' => 'private keys',
        'github_apps' => 'GitHub apps',
        'gitlab_apps' => 'GitLab apps',
        'gitea_apps' => 'Gitea apps',
        's3_storages' => 'S3 storages',
        'cloud_provider_tokens' => 'cloud provider tokens',
        'scheduled_database_backups' => 'database backups',
        'scheduled_volume_backups' => 'volume backups',
        'scheduled_tasks' => 'scheduled tasks',
        'shared_environment_variables' => 'shared variables',
        'taggables' => 'tag links',
        'tags' => 'tags',
    ];

    public function __construct(private readonly ConnectionInterface $db) {}

    public function render(MovePlan $plan, OutputStyle $out, ?GuardResult $guard = null): void
    {
        $out->writeln('');
        $out->writeln(sprintf('<options=bold>%s</> → <options=bold>%s</>', $plan->from->name, $plan->to->name));
        $out->writeln('');

        $this->moves($plan, $out);
        $this->issues($out, 'Blockers', 'red', $plan->issuesAt(IssueLevel::Blocker));
        $this->issues($out, 'Warnings', 'yellow', $plan->issuesAt(IssueLevel::Warning));
        $this->issues($out, 'After the move', 'yellow', $plan->issuesAt(IssueLevel::AfterMove));

        if ($guard !== null && ! $guard->canApply()) {
            $this->issues($out, 'Schema', 'red', [$this->guardMessage($guard)]);
        }
    }

    public static function guardMessage(GuardResult $guard): string
    {
        if (! $guard->versionSupported) {
            return "This Coolify schema ({$guard->lastMigration}) is older than coolhop supports. Update Coolify first.";
        }

        return 'This Coolify schema has columns coolhop does not know: '.implode(', ', $guard->unknownColumns).'. Apply is disabled until coolhop supports them.';
    }

    private function moves(MovePlan $plan, OutputStyle $out): void
    {
        $out->writeln('<options=bold>Moves</>');
        foreach ($plan->servers as $server) {
            $out->writeln("  • server {$server->name} ({$server->ip})");
        }

        $projects = collect($plan->changes)->filter(fn (RowChange $c) => $c->table === 'projects')->map(fn (RowChange $c) => $c->key['id']);
        foreach ($this->db->table('projects')->whereIn('id', $projects)->orderBy('name')->pluck('name') as $name) {
            $out->writeln("  • project {$name}");
        }

        $counts = collect($plan->changes)
            ->reject(fn (RowChange $c) => in_array($c->table, ['servers', 'projects'], true))
            ->groupBy(fn (RowChange $c) => $c->new instanceof CopyRef ? 'repointed '.$this->label($c->table) : $this->label($c->table))
            ->map->count();
        foreach ($counts as $label => $count) {
            $out->writeln("  • {$count} {$label}");
        }

        foreach (collect($plan->copies)->groupBy('table')->map->count() as $table => $count) {
            $out->writeln("  • {$count} {$this->label($table)} copied into {$plan->to->name}");
        }
        $out->writeln('');
    }

    /**
     * @param  list<\App\Analysis\Issue|string>  $issues
     */
    private function issues(OutputStyle $out, string $title, string $color, array $issues): void
    {
        if ($issues === []) {
            return;
        }

        $out->writeln("<fg={$color};options=bold>{$title}</>");
        foreach ($issues as $issue) {
            $out->writeln("  <fg={$color}>•</> ".(is_string($issue) ? $issue : $issue->message));
        }
        $out->writeln('');
    }

    private function label(string $table): string
    {
        return self::LABELS[$table] ?? $table;
    }
}
