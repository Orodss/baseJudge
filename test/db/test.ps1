$ErrorActionPreference = 'Stop'
$project = 'basejudge-test-' + [guid]::NewGuid().ToString('N')
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$composeArgs = @('compose', '--project-name', $project, '-f', (Join-Path $repoRoot 'compose.yaml'), '-f', (Join-Path $PSScriptRoot 'compose.test.yaml'))
$previousEnv = @{}
foreach ($key in @('POSTGRES_USER', 'POSTGRES_DB', 'POSTGRES_PASSWORD')) {
    $previousEnv[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
}

function Invoke-Compose {
    & docker @composeArgs @args
    if ($LASTEXITCODE -ne 0) { throw "Docker Compose failed with exit code $LASTEXITCODE" }
}

try {
    $env:POSTGRES_USER = 'basejudge_test'
    $env:POSTGRES_DB = 'basejudge_test'
    $env:POSTGRES_PASSWORD = [guid]::NewGuid().ToString('N')
    Invoke-Compose config --quiet
    Invoke-Compose up -d --wait postgres
    Invoke-Compose run --rm migrate up 1
    Invoke-Compose run --rm db-test -f /tests/users.sql
    Invoke-Compose run --rm db-test -c "INSERT INTO users (username, display_name, email, password_hash) VALUES ('upgrade_sentinel', 'Upgrade Sentinel', 'upgrade@example.test', 'test-only-hash');"
    Invoke-Compose run --rm migrate up
    Invoke-Compose run --rm db-test
    Invoke-Compose run --rm migrate goto 1
    Invoke-Compose run --rm db-test -c "DO 'BEGIN IF (SELECT count(*) FROM public.users WHERE username = ''upgrade_sentinel'') <> 1 THEN RAISE EXCEPTION ''Upgrade/rollback lost existing user''; END IF; IF (SELECT count(*) FROM information_schema.tables WHERE table_schema = ''public'' AND table_type = ''BASE TABLE'') <> 2 THEN RAISE EXCEPTION ''Rollback to v1 left unexpected tables''; END IF; END';"
    Invoke-Compose run --rm migrate up
    Invoke-Compose run --rm db-test
    Invoke-Compose run --rm migrate down -all
    Invoke-Compose run --rm db-test -c "DO 'BEGIN IF to_regclass(''public.users'') IS NOT NULL THEN RAISE EXCEPTION ''users still exists after down''; END IF; END';"
    Invoke-Compose run --rm migrate up
    Invoke-Compose run --rm db-test
    Write-Output 'All 13 migration units, upgrade preservation, rollback/reapply, and 20-table constraints passed.'
} finally {
    try {
        # This randomly named project contains only this test run's disposable data.
        Invoke-Compose down --volumes --remove-orphans
    } finally {
        foreach ($key in $previousEnv.Keys) {
            [Environment]::SetEnvironmentVariable($key, $previousEnv[$key], 'Process')
        }
    }
}
