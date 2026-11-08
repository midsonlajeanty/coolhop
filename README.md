<p align="center">
  <img src=".github/assets/coolify-logo.svg" alt="Coolify" width="96" height="96">
</p>

<h1 align="center">coolhop</h1>

<p align="center">
  <strong>Move servers between Coolify teams, zero downtime.</strong>
</p>

<p align="center">
  <a href="https://github.com/midsonlajeanty/coolhop/actions/workflows/ci.yml"><img src="https://github.com/midsonlajeanty/coolhop/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://github.com/midsonlajeanty/coolhop/actions/workflows/security.yml"><img src="https://github.com/midsonlajeanty/coolhop/actions/workflows/security.yml/badge.svg" alt="Security"></a>
  <a href="https://github.com/midsonlajeanty/coolhop/releases/latest"><img src="https://img.shields.io/github/v/release/midsonlajeanty/coolhop?sort=semver" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/Coolify-v4.6%2B-864ffc" alt="Coolify v4.6+">
  <img src="https://img.shields.io/badge/PHP-8.4-777bb4" alt="PHP 8.4">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/midsonlajeanty/coolhop" alt="MIT license"></a>
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> ·
  <a href="#what-moves">What moves</a> ·
  <a href="#safety">Safety</a> ·
  <a href="#commands">Commands</a> ·
  <a href="#contributing">Contributing</a>
</p>

---

Coolify v4 has no way to move a server to another team of the same instance. The usual workarounds are rebuilding every resource in the target team, with downtime and lost history, or editing the Coolify database by hand.

**coolhop** does that database edit for you, safely. It runs on your Coolify host, asks which servers to move and where, shows exactly what will change, backs up the database and applies the move in a single transaction. Your applications keep running: nothing restarts and nothing is redeployed.

## Quick start

SSH into the host where Coolify is installed, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/midsonlajeanty/coolhop/main/install.sh | bash
```

The guided mode walks you through it:

1. pick the team the servers belong to now
2. pick the servers to move
3. pick the team that receives them
4. read the plan
5. type the target team name to confirm

Nothing is written before step 5. Nothing needs to be installed on the host: coolhop runs inside the existing `coolify` container.

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
  • 439 audit events

Warnings
  • Platform already has a project named "monitoring". Both will exist side by side.

After the move
  • API tokens of Agency (CI deploy) cannot act on moved resources.
    Create tokens in Platform and update the places that use them.
```

## What moves

A move takes the selected servers and everything they carry:

- the servers, their destinations and their private keys
- every project whose resources all live on those servers, with environments and resources, including the applications and databases inside services
- the Git apps, S3 storages and cloud provider tokens they use: moved, or copied when something that stays still uses them
- database backups, volume backups and scheduled tasks
- server, project and environment variables, plus the team variables (`{{team.X}}`) the moved resources reference
- tags
- the audit history of all of the above, so the target team sees what happened on those servers

coolhop never touches:

- running containers, the proxy or the remote servers
- users, team memberships and invitations
- the `localhost` server, which Coolify ties to the root team

When a move would break something, the plan lists it under **Blockers** and coolhop refuses to apply:

- a project split between moving and staying servers
- a Git app shared with resources that stay
- a build server or a Swarm cluster cut in two
- a deployment in progress
- a reference coolhop does not move yet: managed DNS records, secret manager links, GitHub runners, Cloudflare tunnel integrations

## Safety

| Guarantee | How |
|---|---|
| Dry run first | The plan is always shown, and the guided mode asks you to type the target team name. |
| Backup | Before `apply` and `rollback`, `install.sh` runs `pg_dump` into `/data/coolify/backups/coolhop/backups/<timestamp>/coolify.dump`. |
| All or nothing | Every write happens in one transaction. The plan is recomputed inside it, and nothing is written if the database changed since you read it. |
| Undo | Every changed and created row is recorded in a journal. `rollback` reverts exactly those rows and refuses if anything changed since. |
| Schema guard | coolhop knows every column of the Coolify schema that links rows together. If an update adds one it does not know, `apply` is disabled until coolhop supports it. |

To restore the backup by hand:

```bash
docker exec -i coolify-db pg_restore -U coolify -d coolify --clean --if-exists \
  < /data/coolify/backups/coolhop/backups/<timestamp>/coolify.dump
```

## Commands

Every step of the guided mode also exists as a command, for scripts:

```bash
coolhop="curl -fsSL https://raw.githubusercontent.com/midsonlajeanty/coolhop/main/install.sh"

$coolhop | bash -s -- check
$coolhop | bash -s -- teams
$coolhop | bash -s -- plan  --from=Agency --to=Platform --server=web-1 --server=web-2
$coolhop | bash -s -- apply --from=Agency --to=Platform --server=web-1 --server=web-2 --yes --fingerprint=<printed by plan>
$coolhop | bash -s -- rollback <journal-id> --yes
$coolhop | bash -s -- history <journal-id> --yes
```

| Command | What it does |
|---|---|
| `check` | Tells whether coolhop supports this Coolify schema |
| `teams` | Lists teams and the servers they own |
| `plan` | Shows what a move would change, writes nothing |
| `apply` | Moves the servers |
| `rollback` | Undoes a move recorded in a journal |
| `history` | Moves the audit history left behind by a move made with coolhop 0.1.0 |

| Option | Meaning |
|---|---|
| `--from`, `--to` | team name or id |
| `--server` | server name or uuid, repeatable |
| `--take=table:id` | also move an unused item of the source team, repeatable |
| `--on-variable-clash=keep\|stop` | what to do when a team variable exists in both teams |
| `--json` | `plan` only, machine readable output |
| `--fingerprint` | `apply` only, the value printed by `plan`: apply refuses if the plan changed since |
| `--replan` | `apply` only, apply the plan as it is now instead of a reviewed fingerprint |

Pin a version with `COOLHOP_VERSION=v0.1.0`.

## Requirements

- Coolify v4.6.0 or later, self-hosted
- shell access to the Coolify host, as root or a user allowed to run `docker`
- `curl` and `sha256sum` on the host

## Contributing

Bug reports, schema updates and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) to set up the project, run the tests against the real Coolify schema and check a change on a restored dump.

Found a security issue? Please follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

## License

[MIT](LICENSE)

coolhop is a community project, not affiliated with or endorsed by Coolify or coolLabs. The Coolify logo belongs to its owners and is used here only to show what coolhop works with.
