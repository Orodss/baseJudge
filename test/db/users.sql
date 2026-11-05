BEGIN;

-- All fixtures are rolled back, including when this file is run against a dev DB.
CREATE FUNCTION pg_temp.expect_error(statement text, expected_state text, expected_constraint text)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    actual_constraint text;
BEGIN
    BEGIN
        EXECUTE statement;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS actual_constraint = CONSTRAINT_NAME;
        IF SQLSTATE = expected_state AND actual_constraint = expected_constraint THEN
            RETURN;
        END IF;
        RAISE EXCEPTION 'Expected % / %, got % / %: %',
            expected_state, expected_constraint, SQLSTATE, actual_constraint, SQLERRM;
    END;
    RAISE EXCEPTION 'Statement unexpectedly succeeded: %', statement;
END;
$$;

INSERT INTO users (username, display_name, email, password_hash)
VALUES ('local_user', 'Local User', 'local@example.test', 'test-only-encoded-hash');
INSERT INTO users (username, display_name, email, google_subject)
VALUES ('google_user', 'Google User', 'google@example.test', 'google-subject-1');
INSERT INTO users (username, display_name, email, password_hash, google_subject, role_id)
VALUES ('linked_user', 'Linked User', 'linked@example.test', 'test-only-encoded-hash', 'google-subject-2', 1);
INSERT INTO users (username, display_name, email, disabled_at)
VALUES ('disabled_user', 'Deleted User', 'disabled@example.test', now());

DO $$
DECLARE
    local_account users%ROWTYPE;
BEGIN
    SELECT * INTO STRICT local_account FROM users WHERE username = 'local_user';
    IF local_account.id <= 0 OR local_account.role_id <> 2
       OR local_account.created_at IS NULL OR local_account.updated_at IS NULL
       OR local_account.email_verified_at IS NOT NULL
       OR local_account.disabled_at IS NOT NULL THEN
        RAISE EXCEPTION 'Incorrect users defaults';
    END IF;
    IF (SELECT count(DISTINCT id) FROM users WHERE username IN
        ('local_user', 'google_user', 'linked_user', 'disabled_user')) <> 4 THEN
        RAISE EXCEPTION 'Generated IDs must be distinct';
    END IF;
END;
$$;

SELECT pg_temp.expect_error(
    $q$UPDATE users SET username = 'google_user' WHERE username = 'local_user'$q$,
    '23505', 'users_username_key');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET email = 'google@example.test' WHERE username = 'local_user'$q$,
    '23505', 'users_email_key');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET google_subject = 'google-subject-1' WHERE username = 'local_user'$q$,
    '23505', 'users_google_subject_key');

DO $$
DECLARE
    invalid_username text;
    invalid_email text;
    invalid_role smallint;
BEGIN
    FOREACH invalid_username IN ARRAY ARRAY['', 'ab', repeat('a', 33), 'MixedCase', ' spaced ', 'bad-name', 'a b'] LOOP
        PERFORM pg_temp.expect_error(format('UPDATE users SET username = %L WHERE username = ''local_user''', invalid_username),
            '23514', 'users_username_check');
    END LOOP;
    FOREACH invalid_email IN ARRAY ARRAY['', ' ', 'Mixed@example.test', ' local@example.test '] LOOP
        PERFORM pg_temp.expect_error(format('UPDATE users SET email = %L WHERE username = ''local_user''', invalid_email),
            '23514', 'users_email_check');
    END LOOP;
    FOREACH invalid_role IN ARRAY ARRAY[-1, 0, 3, 999]::smallint[] LOOP
        PERFORM pg_temp.expect_error(format('UPDATE users SET role_id = %s WHERE username = ''local_user''', invalid_role),
            '23514', 'users_role_check');
    END LOOP;
END;
$$;

SELECT pg_temp.expect_error(
    $q$UPDATE users SET display_name = '   ' WHERE username = 'local_user'$q$,
    '23514', 'users_display_name_check');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET display_name = repeat('a', 101) WHERE username = 'local_user'$q$,
    '23514', 'users_display_name_check');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET password_hash = ' ' WHERE username = 'local_user'$q$,
    '23514', 'users_password_hash_check');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET google_subject = ' ' WHERE username = 'google_user'$q$,
    '23514', 'users_google_subject_check');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET password_hash = NULL WHERE username = 'local_user'$q$,
    '23514', 'users_credentials_check');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET disabled_at = NULL WHERE username = 'disabled_user'$q$,
    '23514', 'users_credentials_check');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET role_id = NULL WHERE username = 'local_user'$q$,
    '23502', '');
SELECT pg_temp.expect_error(
    $q$UPDATE users SET email = NULL WHERE username = 'local_user'$q$,
    '23502', '');

-- Multiple NULL Google subjects are valid; unlinking is safe with another credential.
UPDATE users SET google_subject = NULL WHERE username = 'linked_user';
UPDATE users SET password_hash = 'new-test-only-hash', disabled_at = NULL WHERE username = 'disabled_user';
UPDATE users SET username = repeat('a', 32), display_name = repeat('b', 100) WHERE username = 'local_user';

ROLLBACK;
