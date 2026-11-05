# baseJudge backend

Go 1.26.0 and Fiber v3.6.1. The database has 20 application tables across 13
golang-migrate units. Authentication and API database access are not implemented yet.
See [database documentation](documentation/readme.md) and the
[DBML schema](documentation/database.dbml) for the complete structure.

## Local PostgreSQL with Docker Compose

Install/start Docker Desktop using Linux containers (WSL 2 on Windows).
Use Docker Compose v2.24.4 or newer for the test override's `!reset` support.
The images are pinned to PostgreSQL `18.6-bookworm` and golang-migrate `v4.19.1`.

Create a local `.env` from `.env.example` and set `POSTGRES_PASSWORD` to a
random hexadecimal password. For example, in PowerShell from the repository root:

```powershell
Copy-Item .env.example .env
$password = [guid]::NewGuid().ToString('N')
(Get-Content .env) -replace '^POSTGRES_PASSWORD=.*$', "POSTGRES_PASSWORD=$password" | Set-Content .env
docker compose up -d --wait postgres
docker compose run --rm migrate up
docker compose run --rm migrate version
```

Run the copy/generation commands only for initial setup; do not overwrite an
existing `.env`. Keep this file private. The migration service builds a database
URL, so use URL-safe credentials (the generated hex password is suitable).

PostgreSQL is published only on `127.0.0.1:55432` by default to avoid the usual
native PostgreSQL port. The migration container connects internally to
`postgres:5432`. Configure the host port, database, and user through `.env`.
The named volume mounts at `/var/lib/postgresql`, as required by PostgreSQL 18.

```powershell
docker compose stop
docker compose up -d --wait postgres
```

These retain data. Changing `.env` credentials does not update an initialized
database. `docker compose down --volumes` deletes the database volume; do not use
it for routine shutdown. Never run rollback commands on data you need to keep.

## Migrations

SQL up/down files live in `db/migrations/`. Run migrations explicitly; the API
does not run them at startup. The `users` migration enforces canonical username
and email values, unique identities, default guest role, and an authentication
method for active accounts. Google-only accounts may have no password hash.
Application code must validate email format, hash passwords, check Google tokens,
prevent role escalation, and maintain `updated_at`; these are not provided by SQL.

For a new migration, use the locally installed migrate CLI:

```powershell
migrate create -ext sql -dir db/migrations -seq describe_change
```

Keep applied migrations immutable. A down migration for `users` drops that table
and its data. PostgreSQL's initialization creates the database; golang-migrate
creates/version-controls its schema using `schema_migrations`.

Migrations 000002–000013 add sessions/tokens, problem versions and private file
references, contest entries, runtimes, submissions, and judging/rejudge history.
They enforce ownership foreign keys, lifecycle row shapes and partial uniqueness
for active attempts. Source is limited to 256 KiB and infrastructure errors to
8 KiB. Runtime/compiler records are not seeded. Authorization, worker fencing,
version immutability and atomic workflow operations still need application code.

## Tests

```powershell
powershell -NoProfile -File test/db/test.ps1
go test ./...
go vet ./...
go build ./...
```

The database runner creates a randomly named, isolated Compose project with an
in-memory PostgreSQL data directory, no host port, and temporary credentials.
It upgrades a users-only database while retaining a sentinel user, tests all 20
tables, rolls back to version 1, verifies the user survived, reapplies, then tests
a full down/up cycle. Constraints, defaults, ownership, lifecycle shapes, deletion
rules and transaction rollback are checked. It removes only its own project afterward.
It never runs down migrations against the development database.

## Moving to a VPS later

Reuse the migrations and Compose services on a Linux Docker host. Transfer a
consistent PostgreSQL backup rather than copying a running data directory;
restore into the VPS volume and verify it before switching clients. Keep database
ports private, supply deployment credentials externally, and add API/TLS services
when those features are implemented. A volume is persistence, not a backup.
