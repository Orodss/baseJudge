# Database schema

[database.dbml](database.dbml) describes all **20 application tables and 144 columns**
at golang-migrate version **13**. Open it in the dbdocs.io/dbdiagram DBML editor to
view the relationships. These files are local; no hosted project has been published.

The authoritative schema is [db/migrations](../db/migrations/). DBML documents it;
do not use SQL exported from the diagram to migrate the application database.
The migration tool's own `schema_migrations` table is intentionally excluded.

## Structure

| Area | Tables |
| --- | --- |
| Accounts | users, user_sessions, account_tokens |
| Problems and storage | stored_files, problems, problem_versions, tags, problem_tags, problem_editorials, problem_test_cases |
| Contests | contests, contest_problems, contest_registrations, contest_privileged_users |
| Judging | judge_runtimes, submissions, rejudge_batches, judgings, judging_test_results, rejudge_items |

Numeric enum mappings are recorded in table notes and SQL checks. Unknown ID 0 is
not a stored value. Contest phase is derived; runtime/compiler versions are not
invented or seeded. All instants use `timestamptz`.

Composite foreign keys prevent cross-problem versions, cross-submission effective
results, cross-version test results, and cross-batch rejudge candidates. Nullable
pointers use PostgreSQL's default MATCH SIMPLE semantics. Deletions restrict
history; only session/token rows and tag associations cascade.

## Database checks versus application rules

SQL enforces keys, required values, enum ranges, row shapes, ordering, ownership,
source size (256 KiB), infrastructure-error size (8 KiB), and one queued/running
attempt per submission. It also checks judging timestamps and lease-field presence.

Future application code must enforce login/authorization, contest access and source
visibility, registration/exposure exclusion, publication completeness, immutable
used versions/results/runtimes, safe file access, lease ownership/expiry, and atomic
submit/claim/finish/rejudge operations. Schema tests do not prove those behaviors.

## DBML representation limits

The converter represents `GENERATED ALWAYS AS IDENTITY` as `increment`; see SQL
for the exact identity semantics. It omits partial-index predicates. The four
affected indexes have explicit notes in DBML:

| Index | Actual SQL rule |
| --- | --- |
| submissions_competition_idx | WHERE is_competitive |
| judgings_one_active_idx | UNIQUE (submission_id) WHERE status_id IN (1, 2) |
| judgings_queue_idx | WHERE status_id = 1 |
| judgings_expiry_idx | WHERE status_id = 2 |

The active-attempt index deliberately has no global DBML `unique` flag: terminal
judgings may share a submission. Read its note for the actual conditional uniqueness.

## Validate and update locally

Node.js/npm are needed only for documentation tooling, not for the Go application.
The schema was converted and parsed with the official `@dbml/cli@11.0.1`.
From the repository root, parse DBML by exporting it to a temporary SQL file:

```powershell
npm exec --yes --package=@dbml/cli@11.0.1 -- dbml2sql documentation/database.dbml --postgres -o "$env:TEMP/basejudge-dbml-check.sql"
powershell -NoProfile -File test/db/test.ps1
```

When migrations change, update DBML in the same change. To make a fresh comparison
for this initial create-only migration chain, concatenate the sorted `*.up.sql`
files into a temporary SQL file and run:

```powershell
npm exec --yes --package=@dbml/cli@11.0.1 -- sql2dbml "$env:TEMP/basejudge-schema.sql" --postgres -o "$env:TEMP/basejudge-generated.dbml"
```

Review the generated diff before copying it: retain the project/table notes,
restore the four partial-index annotations, and remove the converter's misleading
global uniqueness on `judgings_one_active_idx`. After future ALTER/DROP migrations,
prefer a schema-only dump from a disposable database migrated to the target version
as the conversion input. Never include data, credentials, or a connection string.

## Optional publication to dbdocs.io

Publication is a separate action: it uploads schema metadata to your account.
The [current dbdocs guide](https://docs.dbdiagram.io/dbdocs/) recommends the
`dbdiagram` CLI and its `build document` command; the older `dbdocs` CLI is
deprecated. Follow that guide for authentication and project settings, or create
a project in the browser and load `database.dbml`. Choose access settings before
sharing. This task did not log in or publish.

References: [DBML syntax](https://dbml.dbdiagram.io/docs/),
[official conversion CLI](https://dbml.dbdiagram.io/cli/).
