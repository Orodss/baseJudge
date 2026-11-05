BEGIN;

CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text, expected_constraint text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE actual_constraint text;
BEGIN
    BEGIN
        EXECUTE statement;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
        IF SQLSTATE = expected_state AND (expected_constraint IS NULL OR actual_constraint = expected_constraint) THEN
            RETURN;
        END IF;
        RAISE EXCEPTION 'Expected % / %, got % / %: %', expected_state, expected_constraint, SQLSTATE, actual_constraint, SQLERRM;
    END;
    RAISE EXCEPTION 'Statement unexpectedly succeeded: %', statement;
END;
$$;

-- Fixed negative IDs keep fixtures independent of sequence state across up/down/up.
INSERT INTO users (id, username, display_name, email, password_hash) OVERRIDING SYSTEM VALUE VALUES
    (-1, 'schema_author', 'Author', 'schema-author@example.test', 'fixture-hash'),
    (-2, 'schema_solver', 'Solver', 'schema-solver@example.test', 'fixture-hash'),
    (-3, 'schema_disposable', 'Disposable', 'schema-disposable@example.test', 'fixture-hash');
INSERT INTO user_sessions (id, user_id, token_hash, expires_at) OVERRIDING SYSTEM VALUE
    VALUES (-1, -3, decode(repeat('ab', 32), 'hex'), now() + interval '1 day');
INSERT INTO account_tokens (id, user_id, token_hash, purpose, expires_at) OVERRIDING SYSTEM VALUE
    VALUES (-1, -3, decode(repeat('cd', 32), 'hex'), 'password_reset', now() + interval '1 hour');
INSERT INTO account_tokens (id, user_id, token_hash, purpose, target_email, expires_at) OVERRIDING SYSTEM VALUE
    VALUES (-2, -3, decode(repeat('ef', 32), 'hex'), 'email_verification', 'schema-disposable@example.test', now() + interval '1 hour');
INSERT INTO stored_files (id, storage_key, sha256, size_bytes) OVERRIDING SYSTEM VALUE
    VALUES (-1, 'fixtures/input', decode(repeat('01', 32), 'hex'), 0),
           (-2, 'fixtures/output', decode(repeat('02', 32), 'hex'), 12);
INSERT INTO problems (id, created_by) OVERRIDING SYSTEM VALUE VALUES (-1, -1), (-2, -1);
INSERT INTO problem_versions (id, problem_id, version_number, title, checker_version, created_by)
    OVERRIDING SYSTEM VALUE VALUES (-1, -1, 1, 'First', 'fixture-v1', -1),
                                 (-2, -1, 2, 'Revised', 'fixture-v1', -1),
                                 (-3, -2, 1, 'Other problem', 'fixture-v1', -1);
UPDATE problems SET current_version_id = -1 WHERE id = -1;
UPDATE problems SET current_version_id = -3 WHERE id = -2;
INSERT INTO tags (id, name) OVERRIDING SYSTEM VALUE VALUES (-1, 'graphs');
INSERT INTO problem_tags VALUES (-1, -1);
INSERT INTO problem_editorials (problem_version_id, body, created_by) VALUES (-1, 'Explanation', -1);
INSERT INTO problem_test_cases (id, problem_version_id, position, input_file_id, expected_output_file_id)
    OVERRIDING SYSTEM VALUE VALUES (-1, -1, 1, -1, -2), (-2, -2, 1, -1, -2);
INSERT INTO contests (id, created_by, title, starts_at, ends_at) OVERRIDING SYSTEM VALUE
    VALUES (-1, -1, 'Contest', now(), now() + interval '2 hours'),
           (-2, -1, 'Other contest', now(), now() + interval '2 hours');
INSERT INTO contest_problems VALUES (-1, -1, -1, 'A', 1), (-1, -2, -3, 'B', 2);
INSERT INTO contest_registrations VALUES (-1, -2, now());
INSERT INTO contest_privileged_users VALUES (-1, -1, now());
INSERT INTO judge_runtimes (id, key, compiler_version, environment_digest) OVERRIDING SYSTEM VALUE
    VALUES (-1, 'fixture-cpp', 'test-only', 'test-only');
INSERT INTO submissions (id, user_id, problem_id, submitted_problem_version_id, requested_runtime_id, source_code, submitted_at)
    OVERRIDING SYSTEM VALUE VALUES (-1, -2, -1, -1, -1, 'int main() {}', now()),
                                 (-2, -2, -1, -1, -1, 'int main() {}', now());
INSERT INTO submissions (id, user_id, problem_id, submitted_problem_version_id, requested_runtime_id, source_code, submitted_at, contest_id, is_competitive)
    OVERRIDING SYSTEM VALUE VALUES (-3, -2, -1, -1, -1, 'int main() {}', now(), -1, true);
INSERT INTO rejudge_batches (id, requested_by, reason) OVERRIDING SYSTEM VALUE
    VALUES (-1, -1, 'Correct tests'), (-2, -1, 'Other batch');
INSERT INTO judgings (id, submission_id, attempt_number, problem_id, problem_version_id, runtime_id)
    OVERRIDING SYSTEM VALUE VALUES (-1, -1, 1, -1, -1, -1), (-2, -2, 1, -1, -1, -1);
INSERT INTO rejudge_items (batch_id, submission_id) VALUES (-1, -1);

DO $$
BEGIN
    IF (SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
        AND table_name <> 'schema_migrations') <> 20 THEN RAISE EXCEPTION 'Expected 20 application tables'; END IF;
    IF (SELECT count(*) FROM information_schema.columns WHERE table_schema = 'public'
        AND table_name <> 'schema_migrations') <> 144 THEN RAISE EXCEPTION 'Expected 144 columns'; END IF;
    IF NOT EXISTS (SELECT FROM problems WHERE id = -1 AND publication_status_id = 1 AND difficulty_id IS NULL)
       OR NOT EXISTS (SELECT FROM problem_versions WHERE id = -1 AND statement = '' AND time_limit_ms IS NULL
                      AND memory_limit_bytes IS NULL AND output_limit_bytes IS NULL AND checker_key = 'token')
       OR NOT EXISTS (SELECT FROM problem_test_cases WHERE id = -1 AND NOT is_sample)
       OR NOT EXISTS (SELECT FROM contests WHERE id = -1 AND penalty_minutes = 20 AND publication_status_id = 1
                      AND entry_password_hash IS NULL AND description = '')
       OR NOT EXISTS (SELECT FROM judge_runtimes WHERE id = -1 AND language_key = 'cpp' AND enabled AND compile_flags = '{}')
       OR NOT EXISTS (SELECT FROM submissions WHERE id = -1 AND NOT is_competitive AND contest_id IS NULL AND effective_judging_id IS NULL)
       OR NOT EXISTS (SELECT FROM rejudge_batches WHERE id = -1 AND state_id = 1 AND decided_at IS NULL AND decided_by IS NULL)
       OR NOT EXISTS (SELECT FROM judgings WHERE id = -1 AND status_id = 1 AND verdict_id IS NULL AND lease_token IS NULL)
    THEN RAISE EXCEPTION 'Incorrect schema defaults'; END IF;
END;
$$;

-- Each invalid write must fail for the intended check, not an unrelated SQL error.
DO $$
DECLARE test record;
BEGIN
    FOR test IN SELECT * FROM (VALUES
        ('user_sessions', 'token_hash = decode(''ab'', ''hex'')', 'user_sessions_token_hash_check'),
        ('user_sessions', 'expires_at = created_at', 'user_sessions_expiry_check'),
        ('user_sessions', 'revoked_at = created_at - interval ''1 second''', 'user_sessions_revocation_check'),
        ('account_tokens', 'token_hash = decode(''ab'', ''hex'')', 'account_tokens_token_hash_check'),
        ('account_tokens', 'purpose = ''other''', 'account_tokens_purpose_check'),
        ('account_tokens', 'purpose = ''email_verification'', target_email = NULL', 'account_tokens_target_email_check'),
        ('account_tokens', 'purpose = ''password_reset'', target_email = ''x@y.test''', 'account_tokens_target_email_check'),
        ('account_tokens', 'purpose = ''email_verification'', target_email = '' X@Y.test ''', 'account_tokens_target_email_check'),
        ('account_tokens', 'expires_at = created_at', 'account_tokens_expiry_check'),
        ('account_tokens', 'consumed_at = created_at - interval ''1 second''', 'account_tokens_consumption_check'),
        ('stored_files', 'storage_key = '' ''', 'stored_files_key_check'),
        ('stored_files', 'sha256 = decode(''ab'', ''hex'')', 'stored_files_hash_check'),
        ('stored_files', 'size_bytes = -1', 'stored_files_size_check'),
        ('problems', 'publication_status_id = 0', 'problems_publication_status_check'),
        ('problems', 'difficulty_id = 0', 'problems_difficulty_check'),
        ('problems', 'publication_status_id = 2, difficulty_id = NULL', 'problems_published_check'),
        ('problems', 'publication_status_id = 2, difficulty_id = 1, current_version_id = NULL', 'problems_published_check'),
        ('problem_versions', 'version_number = 0', 'problem_versions_number_check'),
        ('problem_versions', 'title = '' ''', 'problem_versions_title_check'),
        ('problem_versions', 'time_limit_ms = 0', 'problem_versions_time_check'),
        ('problem_versions', 'memory_limit_bytes = 0', 'problem_versions_memory_check'),
        ('problem_versions', 'output_limit_bytes = 0', 'problem_versions_output_check'),
        ('problem_versions', 'checker_key = '' ''', 'problem_versions_checker_key_check'),
        ('problem_versions', 'checker_version = '' ''', 'problem_versions_checker_version_check'),
        ('tags', 'name = ''Graphs''', 'tags_name_check'),
        ('problem_editorials', 'body = '' ''', 'problem_editorials_body_check'),
        ('problem_editorials', 'publication_status_id = 0', 'problem_editorials_publication_status_check'),
        ('problem_test_cases', 'position = 0', 'problem_test_cases_position_check'),
        ('contests', 'title = '' ''', 'contests_title_check'),
        ('contests', 'publication_status_id = 0', 'contests_publication_status_check'),
        ('contests', 'ends_at = starts_at', 'contests_schedule_check'),
        ('contests', 'entry_password_hash = '' ''', 'contests_password_check'),
        ('contests', 'penalty_minutes = -1', 'contests_penalty_check'),
        ('contest_problems', 'label = '' ''', 'contest_problems_label_check'),
        ('contest_problems', 'position = 0', 'contest_problems_position_check'),
        ('judge_runtimes', 'key = '' ''', 'judge_runtimes_key_check'),
        ('judge_runtimes', 'language_key = ''python''', 'judge_runtimes_language_check'),
        ('judge_runtimes', 'compiler_version = '' ''', 'judge_runtimes_compiler_check'),
        ('judge_runtimes', 'environment_digest = '' ''', 'judge_runtimes_environment_check'),
        ('judge_runtimes', 'compile_flags = ARRAY[NULL]::text[]', 'judge_runtimes_flags_check'),
        ('judge_runtimes', 'compile_flags = ARRAY[[''-O2''], [''-Wall'']]', 'judge_runtimes_flags_check'),
        ('submissions', 'contest_id = NULL, is_competitive = true', 'submissions_competitive_check'),
        ('submissions', 'source_code = '' ''', 'submissions_source_check'),
        ('submissions', 'source_code = repeat(''a'', 262145)', 'submissions_source_check'),
        ('submissions', 'source_code = repeat(chr(233), 131073)', 'submissions_source_check'),
        ('rejudge_batches', 'reason = '' ''', 'rejudge_batches_reason_check'),
        ('rejudge_batches', 'state_id = 0', NULL),
        ('rejudge_batches', 'state_id = 3', 'rejudge_batches_decision_check'),
        ('rejudge_batches', 'decided_by = -1', 'rejudge_batches_decision_check'),
        ('rejudge_batches', 'state_id = 4, decided_by = -1, decided_at = created_at - interval ''1 second''', 'rejudge_batches_time_check'),
        ('judgings', 'attempt_number = 0', 'judgings_attempt_check'),
        ('judgings', 'status_id = 2', 'judgings_lifecycle_check')
    ) AS cases(table_name, assignment, constraint_name)
    LOOP
        PERFORM pg_temp.expect_error(format('UPDATE %I SET %s WHERE ctid = (SELECT ctid FROM %I LIMIT 1)',
            test.table_name, test.assignment, test.table_name), '23514', test.constraint_name);
    END LOOP;
END;
$$;

SELECT pg_temp.expect_error('UPDATE problems SET current_version_id = -3 WHERE id = -1', '23503', 'problems_current_version_fk');
SELECT pg_temp.expect_error('UPDATE contest_problems SET problem_version_id = -3 WHERE problem_id = -1', '23503', 'contest_problems_version_fk');
SELECT pg_temp.expect_error('UPDATE submissions SET submitted_problem_version_id = -3 WHERE id = -1', '23503', 'submissions_version_fk');
SELECT pg_temp.expect_error('UPDATE submissions SET contest_id = -2 WHERE id = -1', '23503', 'submissions_contest_problem_fk');
SELECT pg_temp.expect_error('UPDATE submissions SET effective_judging_id = -2 WHERE id = -1', '23503', 'submissions_effective_judging_fk');
SELECT pg_temp.expect_error('UPDATE judgings SET problem_id = -2, problem_version_id = -3 WHERE id = -1', '23503', 'judgings_submission_fk');
SELECT pg_temp.expect_error('UPDATE judgings SET problem_version_id = -3 WHERE id = -1', '23503', 'judgings_version_fk');
SELECT pg_temp.expect_error('INSERT INTO judgings (submission_id, attempt_number, problem_id, problem_version_id, runtime_id) VALUES (-1, 2, -1, -1, -1)', '23505', 'judgings_one_active_idx');
SELECT pg_temp.expect_error('INSERT INTO contest_problems VALUES (-1, -2, -3, ''C'', 3)', '23505', 'contest_problems_pkey');
SELECT pg_temp.expect_error('UPDATE contest_problems SET label = ''A'' WHERE problem_id = -2', '23505', 'contest_problems_contest_id_label_key');
SELECT pg_temp.expect_error('UPDATE contest_problems SET position = 1 WHERE problem_id = -2', '23505', 'contest_problems_contest_id_position_key');
SELECT pg_temp.expect_error('UPDATE problem_versions SET version_number = 1 WHERE id = -2', '23505', 'problem_versions_problem_id_version_number_key');
SELECT pg_temp.expect_error('INSERT INTO problem_test_cases (problem_version_id, position, input_file_id, expected_output_file_id) VALUES (-1, 1, -1, -2)', '23505', 'problem_test_cases_problem_version_id_position_key');
SELECT pg_temp.expect_error('INSERT INTO user_sessions (user_id, token_hash, expires_at) SELECT user_id, token_hash, expires_at FROM user_sessions', '23505', 'user_sessions_token_hash_key');
SELECT pg_temp.expect_error('INSERT INTO account_tokens (user_id, token_hash, purpose, expires_at) SELECT user_id, token_hash, purpose, expires_at FROM account_tokens WHERE id = -1', '23505', 'account_tokens_token_hash_key');
SELECT pg_temp.expect_error('INSERT INTO stored_files (storage_key, sha256, size_bytes) SELECT storage_key, sha256, size_bytes FROM stored_files WHERE id = -1', '23505', 'stored_files_storage_key_key');
SELECT pg_temp.expect_error('INSERT INTO tags (name) VALUES (''graphs'')', '23505', 'tags_name_key');
SELECT pg_temp.expect_error('INSERT INTO problem_tags VALUES (-1, -1)', '23505', 'problem_tags_pkey');
SELECT pg_temp.expect_error('INSERT INTO problem_editorials (problem_version_id, body, created_by) VALUES (-1, ''Duplicate'', -1)', '23505', 'problem_editorials_pkey');
SELECT pg_temp.expect_error('INSERT INTO contest_registrations VALUES (-1, -2, now())', '23505', 'contest_registrations_pkey');
SELECT pg_temp.expect_error('INSERT INTO contest_privileged_users VALUES (-1, -1, now())', '23505', 'contest_privileged_users_pkey');
SELECT pg_temp.expect_error('INSERT INTO judge_runtimes (key, compiler_version, environment_digest) VALUES (''fixture-cpp'', ''test'', ''test'')', '23505', 'judge_runtimes_key_key');
SELECT pg_temp.expect_error('INSERT INTO rejudge_items (batch_id, submission_id) VALUES (-1, -1)', '23505', 'rejudge_items_pkey');

-- A valid claim, per-test result and finish; future worker code must additionally enforce leases and authorization.
UPDATE judgings SET status_id = 2, started_at = queued_at, worker_key = 'fixture-worker',
    lease_token = '00000000-0000-0000-0000-000000000001', lease_expires_at = queued_at + interval '1 minute' WHERE id = -1;
SELECT pg_temp.expect_error('UPDATE judgings SET lease_token = NULL WHERE id = -1', '23514', 'judgings_lifecycle_check');
SELECT pg_temp.expect_error('UPDATE judgings SET lease_expires_at = started_at WHERE id = -1', '23514', 'judgings_lease_check');
SELECT pg_temp.expect_error('UPDATE judgings SET worker_key = '' '' WHERE id = -1', '23514', 'judgings_worker_check');
SELECT pg_temp.expect_error('UPDATE judgings SET started_at = queued_at - interval ''1 second'' WHERE id = -1', '23514', 'judgings_start_check');
INSERT INTO judging_test_results (judging_id, test_case_id, problem_version_id, verdict_id) VALUES (-1, -1, -1, 1);
SELECT pg_temp.expect_error('INSERT INTO judging_test_results (judging_id, test_case_id, problem_version_id, verdict_id) VALUES (-1, -1, -1, 1)', '23505', 'judging_test_results_pkey');
SELECT pg_temp.expect_error('UPDATE judging_test_results SET test_case_id = -2', '23503', 'judging_test_results_test_fk');
SELECT pg_temp.expect_error('UPDATE judging_test_results SET problem_version_id = -2, test_case_id = -2', '23503', 'judging_test_results_judging_fk');
SELECT pg_temp.expect_error('UPDATE judging_test_results SET verdict_id = 6', '23514', 'judging_test_results_verdict_check');
SELECT pg_temp.expect_error('UPDATE judging_test_results SET runtime_ms = -1', '23514', 'judging_test_results_runtime_check');
SELECT pg_temp.expect_error('UPDATE judging_test_results SET memory_bytes = -1', '23514', 'judging_test_results_memory_check');
UPDATE judgings SET status_id = 3, verdict_id = 1, finished_at = started_at, lease_token = NULL, lease_expires_at = NULL WHERE id = -1;
SELECT pg_temp.expect_error('UPDATE judgings SET verdict_id = 7 WHERE id = -1', '23514', 'judgings_verdict_check');
SELECT pg_temp.expect_error('UPDATE judgings SET verdict_id = NULL WHERE id = -1', '23514', 'judgings_lifecycle_check');
SELECT pg_temp.expect_error('UPDATE judgings SET finished_at = queued_at - interval ''1 second'' WHERE id = -1', '23514', 'judgings_finish_check');
UPDATE submissions SET effective_judging_id = -1 WHERE id = -1;

-- Staged rejudging keeps the baseline selected until an explicit apply transaction.
INSERT INTO judgings (id, submission_id, attempt_number, problem_id, problem_version_id, runtime_id, rejudge_batch_id)
    OVERRIDING SYSTEM VALUE VALUES (-3, -1, 2, -1, -2, -1, -1);
UPDATE rejudge_items SET baseline_judging_id = -1, candidate_judging_id = -3;
-- Roll back both pointer and batch changes when one operation fails midway.
DO $$
BEGIN
    BEGIN
        UPDATE submissions SET effective_judging_id = -3 WHERE id = -1;
        UPDATE rejudge_batches SET state_id = 3 WHERE id = -1;
        RAISE EXCEPTION 'Invalid batch decision unexpectedly succeeded';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    IF (SELECT effective_judging_id FROM submissions WHERE id = -1) <> -1
       OR (SELECT state_id FROM rejudge_batches WHERE id = -1) <> 1 THEN
        RAISE EXCEPTION 'Failed transaction leaked partial batch updates';
    END IF;
END;
$$;
SELECT pg_temp.expect_error('UPDATE rejudge_items SET baseline_judging_id = -2', '23503', 'rejudge_items_baseline_fk');
SELECT pg_temp.expect_error('UPDATE rejudge_items SET candidate_judging_id = -2', '23503', 'rejudge_items_candidate_fk');
SELECT pg_temp.expect_error('UPDATE rejudge_items SET batch_id = -2', '23503', 'rejudge_items_candidate_fk');
UPDATE judgings SET status_id = 4, finished_at = queued_at, infrastructure_error = 'fixture failure before claim' WHERE id = -3;
SELECT pg_temp.expect_error('UPDATE judgings SET infrastructure_error = repeat(''x'', 8193) WHERE id = -3', '23514', 'judgings_error_check');
SELECT pg_temp.expect_error('UPDATE judgings SET infrastructure_error = '' '' WHERE id = -3', '23514', 'judgings_error_check');
SELECT pg_temp.expect_error('UPDATE judgings SET infrastructure_error = NULL WHERE id = -3', '23514', 'judgings_lifecycle_check');
SELECT pg_temp.expect_error('UPDATE judgings SET status_id = 0 WHERE id = -3', '23514');
DO $$
DECLARE value smallint;
BEGIN
    FOREACH value IN ARRAY ARRAY[1,2,3,4,5,6]::smallint[] LOOP
        UPDATE judgings SET verdict_id = value WHERE id = -1;
    END LOOP;
    FOREACH value IN ARRAY ARRAY[0,7,-1]::smallint[] LOOP
        PERFORM pg_temp.expect_error(format('UPDATE judgings SET verdict_id = %s WHERE id = -1', value), '23514', 'judgings_verdict_check');
        PERFORM pg_temp.expect_error(format('UPDATE judging_test_results SET verdict_id = %s', value), '23514', 'judging_test_results_verdict_check');
    END LOOP;
    IF (SELECT effective_judging_id FROM submissions WHERE id = -1) <> -1 THEN
        RAISE EXCEPTION 'Staged failure replaced effective result';
    END IF;
END;
$$;
UPDATE rejudge_batches SET state_id = 2 WHERE id = -2;
UPDATE rejudge_batches SET state_id = 3, decided_by = -1, decided_at = created_at WHERE id = -2;
UPDATE rejudge_batches SET state_id = 4, decided_by = -1, decided_at = created_at WHERE id = -1;
UPDATE submissions SET source_code = repeat('a', 262144) WHERE id = -3;
UPDATE judgings SET infrastructure_error = repeat('a', 8192) WHERE id = -3;

-- Exercise every required column and every simple FK against a real populated table.
DO $$
DECLARE item record;
BEGIN
    FOR item IN SELECT table_name, column_name, is_identity FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name NOT IN ('users', 'schema_migrations') AND is_nullable = 'NO'
    LOOP
        PERFORM pg_temp.expect_error(format('UPDATE %I SET %I = NULL WHERE ctid = (SELECT ctid FROM %I LIMIT 1)',
            item.table_name, item.column_name, item.table_name),
            CASE WHEN item.is_identity = 'YES' THEN '428C9' ELSE '23502' END);
    END LOOP;
    FOR item IN SELECT c.conrelid::regclass AS table_name, a.attname AS column_name, c.conname
        FROM pg_constraint c JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = c.conkey[1]
        WHERE c.contype = 'f' AND cardinality(c.conkey) = 1 AND c.connamespace = 'public'::regnamespace
    LOOP
        PERFORM pg_temp.expect_error(format('UPDATE %s SET %I = -999999 WHERE ctid = (SELECT ctid FROM %s LIMIT 1)',
            item.table_name, item.column_name, item.table_name), '23503');
    END LOOP;
END;
$$;

SELECT pg_temp.expect_error('DELETE FROM users WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM users WHERE id = -2', '23001');
SELECT pg_temp.expect_error('DELETE FROM problems WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM problem_versions WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM stored_files WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM contests WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM contest_problems WHERE problem_id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM submissions WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM judgings WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM judge_runtimes WHERE id = -1', '23001');
SELECT pg_temp.expect_error('DELETE FROM rejudge_batches WHERE id = -1', '23001');
DELETE FROM tags WHERE id = -1;
DELETE FROM users WHERE id = -3;
DO $$
BEGIN
    IF EXISTS (SELECT FROM problem_tags WHERE tag_id = -1)
       OR EXISTS (SELECT FROM user_sessions WHERE user_id = -3)
       OR EXISTS (SELECT FROM account_tokens WHERE user_id = -3) THEN
        RAISE EXCEPTION 'Disposable associations/tokens did not cascade';
    END IF;
END;
$$;

ROLLBACK;
\echo 'Full schema constraints and lifecycle shapes passed.'
