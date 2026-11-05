BEGIN;
CREATE TABLE judge_runtimes (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    key text NOT NULL UNIQUE,
    language_key text NOT NULL DEFAULT 'cpp',
    compiler_version text NOT NULL,
    compile_flags text[] NOT NULL DEFAULT '{}',
    environment_digest text NOT NULL,
    enabled boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT judge_runtimes_key_check CHECK (btrim(key) <> ''),
    CONSTRAINT judge_runtimes_language_check CHECK (language_key = 'cpp'),
    CONSTRAINT judge_runtimes_compiler_check CHECK (btrim(compiler_version) <> ''),
    CONSTRAINT judge_runtimes_environment_check CHECK (btrim(environment_digest) <> ''),
    CONSTRAINT judge_runtimes_flags_check CHECK (
        cardinality(compile_flags) = 0
        OR (array_ndims(compile_flags) = 1 AND array_position(compile_flags, NULL) IS NULL)
    )
);
COMMIT;
