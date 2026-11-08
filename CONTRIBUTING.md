# Contributing to coolhop

Thanks for helping. coolhop edits a production database, so every change needs a test that proves it.

## Setup

```bash
git clone https://github.com/midsonlajeanty/coolhop.git
cd coolhop
composer install
docker compose up -d pg
lefthook install
```

## Checks

```bash
composer test
composer lint
```

Tests run against the real Coolify schema in `tests/fixtures/schema.sql`, which holds no data. Build fixtures with `Tests\Support\Fixture`.

## Supporting a new Coolify version

1. `bin/dump-schema --upstream <version>` rebuilds `tests/fixtures/schema.sql` and `app/Schema/ReferenceColumns.php` from the official migrations.
2. Review every new `*_id`, `*_type` and `team_id` column in the diff: decide whether a move must follow it, copy it, or block on it.
3. Add the rule and a test for each new column, then update `app/Schema/KnownSchema.php`.

## Trying a change on a real dump

Restore a Coolify dump into a throwaway Postgres container, then:

```bash
php coolhop app:build coolhop.phar
bin/acceptance <container> --from=<team> --to=<team> --server=<server>
```

It runs plan, apply and rollback and checks that the data is identical afterwards. Never commit a dump, and never put real team, server or project names in tests, docs or issues.

## Commits and pull requests

- Conventional commits, one subject line: `feat: ...`, `fix: ...`, `docs: ...`.
- One coherent change per commit.
- Code, comments, tests and docs are in English.
