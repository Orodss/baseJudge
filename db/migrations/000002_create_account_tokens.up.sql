BEGIN;

CREATE TABLE user_sessions (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash bytea NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    CONSTRAINT user_sessions_token_hash_check CHECK (octet_length(token_hash) = 32),
    CONSTRAINT user_sessions_expiry_check CHECK (expires_at > created_at),
    CONSTRAINT user_sessions_revocation_check CHECK (revoked_at >= created_at)
);
CREATE INDEX user_sessions_user_idx ON user_sessions(user_id);
CREATE INDEX user_sessions_expiry_idx ON user_sessions(expires_at);

CREATE TABLE account_tokens (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash bytea NOT NULL UNIQUE,
    purpose text NOT NULL,
    target_email text,
    created_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    consumed_at timestamptz,
    CONSTRAINT account_tokens_token_hash_check CHECK (octet_length(token_hash) = 32),
    CONSTRAINT account_tokens_purpose_check CHECK (purpose IN ('email_verification', 'password_reset')),
    CONSTRAINT account_tokens_target_email_check CHECK (
        (purpose = 'email_verification' AND target_email IS NOT NULL
         AND target_email <> '' AND target_email = lower(btrim(target_email)))
        OR (purpose = 'password_reset' AND target_email IS NULL)
    ),
    CONSTRAINT account_tokens_expiry_check CHECK (expires_at > created_at),
    CONSTRAINT account_tokens_consumption_check CHECK (consumed_at >= created_at)
);
CREATE INDEX account_tokens_user_idx ON account_tokens(user_id);
CREATE INDEX account_tokens_expiry_idx ON account_tokens(expires_at);

COMMIT;
