<?php

namespace App\Analysis;

use App\Instance\HostedResource;
use App\Instance\Inventory;
use App\Instance\Server;
use App\Instance\Team;
use App\Security\Decryptor;
use Illuminate\Database\ConnectionInterface;

final class PlanBuilder
{
    private const array SERVICE_PARTS = [
        'service_applications' => 'App\\Models\\ServiceApplication',
        'service_databases' => 'App\\Models\\ServiceDatabase',
    ];

    /** @var list<RowChange> */
    private array $changes = [];

    /** @var array<string, RowCopy> */
    private array $copies = [];

    /** @var list<Issue> */
    private array $issues = [];

    /** @var list<array{table: string, id: int, name: string}> */
    private array $unused = [];

    /** @var array<int, true> */
    private array $movingProjects = [];

    /**
     * @param  list<Server>  $servers
     * @param  list<HostedResource>  $sourceResources
     */
    public function __construct(
        public readonly ConnectionInterface $db,
        public readonly Inventory $inventory,
        public readonly Decryptor $decryptor,
        public readonly MoveRequest $request,
        public readonly Team $from,
        public readonly Team $to,
        public readonly array $servers,
        public readonly array $sourceResources,
    ) {}

    /**
     * @param  array<string, int|string>  $key
     */
    public function change(string $table, array $key, string $column, int|string|null $old, int|string|CopyRef|null $new): void
    {
        $this->changes[] = new RowChange($table, $key, $column, $old, $new);
    }

    public function moveToTarget(string $table, int $id): void
    {
        $this->change($table, ['id' => $id], 'team_id', $this->from->id, $this->to->id);
    }

    /**
     * @param  array<string, int|string|null>  $overrides
     */
    public function copy(string $table, int $sourceId, array $overrides = []): CopyRef
    {
        $ref = "{$table}:{$sourceId}";
        $this->copies[$ref] ??= new RowCopy($ref, $table, $sourceId, ['team_id' => $this->to->id, ...$overrides]);

        return new CopyRef($ref);
    }

    public function issue(IssueLevel $level, string $code, string $message): void
    {
        $this->issues[] = new Issue($level, $code, $message);
    }

    public function unused(string $table, int $id, string $name): void
    {
        $this->unused[] = ['table' => $table, 'id' => $id, 'name' => $name];
    }

    public function moveProject(int $projectId): void
    {
        $this->movingProjects[$projectId] = true;
        $this->moveToTarget('projects', $projectId);
    }

    public function isMovingServer(int $serverId): bool
    {
        return in_array($serverId, $this->serverIds(), true);
    }

    public function isMovingProject(int $projectId): bool
    {
        return isset($this->movingProjects[$projectId]);
    }

    /**
     * @return list<int>
     */
    public function serverIds(): array
    {
        return array_map(fn (Server $s): int => $s->id, $this->servers);
    }

    /**
     * @return array<string, list<int>>
     */
    public function movingMorphs(): array
    {
        $morphs = [];
        foreach ($this->movingResources() as $resource) {
            $morphs[$resource->morphClass()][] = $resource->id;
        }

        $services = array_map(fn (HostedResource $r): int => $r->id, $this->movingResources('services'));
        foreach (self::SERVICE_PARTS as $table => $morph) {
            $ids = $this->db->table($table)->whereIn('service_id', $services)->orderBy('id')->pluck('id')->map(fn ($id): int => (int) $id)->all();
            if ($ids !== []) {
                $morphs[$morph] = array_values($ids);
            }
        }

        return $morphs;
    }

    /**
     * @return list<HostedResource>
     */
    public function movingResources(?string $table = null): array
    {
        return array_values(array_filter(
            $this->sourceResources,
            fn (HostedResource $r): bool => $this->isMovingProject($r->projectId) && ($table === null || $r->table === $table),
        ));
    }

    /**
     * @return list<HostedResource>
     */
    public function stayingResources(?string $table = null): array
    {
        return array_values(array_filter(
            $this->sourceResources,
            fn (HostedResource $r): bool => ! $this->isMovingProject($r->projectId) && ($table === null || $r->table === $table),
        ));
    }

    public function serverName(?int $serverId): string
    {
        return $this->db->table('servers')->where('id', $serverId)->value('name') ?? 'unknown server';
    }

    public function build(): MovePlan
    {
        return new MovePlan($this->from, $this->to, $this->servers, $this->changes, array_values($this->copies), $this->issues, $this->unused);
    }
}
