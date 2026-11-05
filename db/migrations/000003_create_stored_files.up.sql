BEGIN;
CREATE TABLE stored_files (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    storage_key text NOT NULL UNIQUE,
    sha256 bytea NOT NULL,
    size_bytes bigint NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT stored_files_key_check CHECK (btrim(storage_key) <> ''),
    CONSTRAINT stored_files_hash_check CHECK (octet_length(sha256) = 32),
    CONSTRAINT stored_files_size_check CHECK (size_bytes >= 0)
);
COMMIT;
