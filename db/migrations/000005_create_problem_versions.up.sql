BEGIN;
CREATE TABLE problem_versions (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    problem_id bigint NOT NULL REFERENCES problems(id) ON DELETE RESTRICT,
    version_number integer NOT NULL,
    title text NOT NULL,
    statement text NOT NULL DEFAULT '',
    time_limit_ms integer,
    memory_limit_bytes bigint,
    output_limit_bytes bigint,
    checker_key text NOT NULL DEFAULT 'token',
    checker_version text NOT NULL,
    created_by bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (problem_id, version_number),
    UNIQUE (problem_id, id),
    CONSTRAINT problem_versions_number_check CHECK (version_number > 0),
    CONSTRAINT problem_versions_title_check CHECK (btrim(title) <> ''),
    CONSTRAINT problem_versions_time_check CHECK (time_limit_ms > 0),
    CONSTRAINT problem_versions_memory_check CHECK (memory_limit_bytes > 0),
    CONSTRAINT problem_versions_output_check CHECK (output_limit_bytes > 0),
    CONSTRAINT problem_versions_checker_key_check CHECK (btrim(checker_key) <> ''),
    CONSTRAINT problem_versions_checker_version_check CHECK (btrim(checker_version) <> '')
);
CREATE INDEX problem_versions_creator_idx ON problem_versions(created_by);
ALTER TABLE problems ADD CONSTRAINT problems_current_version_fk
    FOREIGN KEY (id, current_version_id) REFERENCES problem_versions(problem_id, id) ON DELETE RESTRICT;
COMMIT;
