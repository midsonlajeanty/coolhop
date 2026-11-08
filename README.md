# coolhop

Move servers between Coolify teams, zero downtime.

```bash
curl -fsSL https://raw.githubusercontent.com/midsonlajeanty/coolhop/main/install.sh | bash
```

Run it over SSH on the host where Coolify is installed. coolhop asks which servers to move and to which team, shows exactly what will change, backs up the Coolify database and applies the move in a single transaction.

## Why

Coolify v4 has no way to move a server to another team of the same instance. The usual workarounds are rebuilding every resource in the target team, with downtime and lost history, or editing the database by hand. coolhop does the database edit for you, safely.

## What it does

A move takes the selected servers and everything they carry:

- the servers, their destinations and their private keys
- every project whose resources all live on those servers, with environments and resources
- the Git apps, S3 storages and cloud provider tokens they use (moved, or copied when something that stays still uses them)
- database backups, volume backups and scheduled tasks
- server, project and environment variables, plus the team variables (`{{team.X}}`) the moved resources reference
- tags

## What it never touches

- running containers, the proxy, the remote servers: nothing restarts and no deployment is triggered
- users, team memberships and invitations
- the `localhost` server, which Coolify ties to the root team

## What a plan looks like

```text
Agency → Platform

Moves
  • server web-1 (203.0.113.10)
  • server web-2 (203.0.113.11)
  • project shop
  • project blog
  • 2 GitHub apps
  • 4 private keys
  • 1 database backups
  • 7 tags copied into Platform

Warnings
  • Platform already has a project named "monitoring". Both will exist side by side.

After the move
  • API tokens of Agency (CI deploy) cannot act on moved resources.
    Create tokens in Platform and update the places that use them.
```

When something would break, the plan lists it under **Blockers** and coolhop refuses to apply: a project split between moving and staying servers, a Git app shared with resources that stay, a build server or Swarm cluster cut in two, a deployment in progress, or a reference coolhop does not move yet (managed DNS records, secret manager links, GitHub runners, Cloudflare tunnel integrations).

## Commands

The guided mode starts when no command is given. Every step also has flags, for scripts:

```bash
install.sh | bash -s -- check
install.sh | bash -s -- teams
install.sh | bash -s -- plan  --from="HQ" --to="PAAS" --server="srv-1" --server="srv-2"
install.sh | bash -s -- apply --from="HQ" --to="PAAS" --server="srv-1" --yes --fingerprint=<printed by plan>
install.sh | bash -s -- rollback 20261108-202318-4bb2 --yes
```

where `install.sh` stands for `curl -fsSL https://raw.githubusercontent.com/midsonlajeanty/coolhop/main/install.sh`.

| Option | Meaning |
|---|---|
| `--from`, `--to` | team name or id |
| `--server` | server name or uuid, repeatable |
| `--take=table:id` | also move an unused item of the source team, repeatable |
| `--on-variable-clash=keep\|stop` | what to do when a team variable exists in both teams |
| `--json` | `plan` only, machine readable output |
| `--fingerprint` | `apply` only, the value printed by `plan`: apply refuses if the plan changed since |
| `--replan` | `apply` only, apply the plan as it is now instead of a reviewed fingerprint |

Pin a version with `COOLHOP_VERSION=v1.0.0`.

## Safety

- **Dry run first.** Nothing is written before you confirm by typing the target team name.
- **Backup.** Before `apply` and `rollback`, `install.sh` runs `pg_dump` into `/data/coolify/backups/coolhop/backups/<timestamp>/coolify.dump`.
- **One transaction.** The plan is recomputed inside the transaction. If the database changed since you saw it, nothing is written.
- **Journal.** Every changed and created row is recorded in `/data/coolify/backups/coolhop/<journal-id>/journal.json`. `rollback` reverts exactly those rows, and refuses if any of them changed since.
- **Schema guard.** coolhop knows every column of the Coolify schema that points to a team. If an update adds one it does not know, `apply` is disabled until coolhop supports it.

To restore the backup by hand:

```bash
docker exec -i coolify-db pg_restore -U coolify -d coolify --clean --if-exists < /data/coolify/backups/coolhop/backups/<timestamp>/coolify.dump
```

## Supported versions

Coolify v4.6.0 and later. Older schemas are refused.

## Development

```bash
composer install
docker compose up -d pg
composer test
composer lint
```

Tests run against the real Coolify schema in `tests/fixtures/schema.sql`, built from the upstream migrations with `bin/dump-schema --upstream <version>` and holding no data. A weekly workflow runs `coolhop check` against the latest Coolify release. `bin/acceptance <container> <plan options>` runs plan, apply and rollback against a restored Coolify dump and checks that the data is identical afterwards.

## License

MIT
