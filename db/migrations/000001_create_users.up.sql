BEGIN;

CREATE TABLE users (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username text NOT NULL,
    display_name text NOT NULL,
    email text NOT NULL,
    email_verified_at timestamptz,
    password_hash text,
    google_subject text,
    role_id smallint NOT NULL DEFAULT 2,
    disabled_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT users_username_key UNIQUE (username),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_google_subject_key UNIQUE (google_subject),
    CONSTRAINT users_username_check CHECK (
        username ~ '^[a-z0-9_]{3,32}$'
    ),
    CONSTRAINT users_display_name_check CHECK (
        char_length(btrim(display_name)) BETWEEN 1 AND 100
    ),
    CONSTRAINT users_email_check CHECK (
        email <> '' AND email = lower(btrim(email))
    ),
    CONSTRAINT users_role_check CHECK (role_id IN (1, 2)),
    CONSTRAINT users_password_hash_check CHECK (
        password_hash IS NULL OR btrim(password_hash) <> ''
    ),
    CONSTRAINT users_google_subject_check CHECK (
        google_subject IS NULL OR btrim(google_subject) <> ''
    ),
    CONSTRAINT users_credentials_check CHECK (
        disabled_at IS NOT NULL
        OR password_hash IS NOT NULL
        OR google_subject IS NOT NULL
    )
);

COMMIT;
