BEGIN;
CREATE TABLE tags (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT tags_name_check CHECK (name <> '' AND name = lower(btrim(name)))
);
CREATE TABLE problem_tags (
    problem_id bigint NOT NULL REFERENCES problems(id) ON DELETE CASCADE,
    tag_id bigint NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (problem_id, tag_id)
);
CREATE INDEX problem_tags_tag_idx ON problem_tags(tag_id, problem_id);
CREATE TABLE problem_editorials (
    problem_version_id bigint PRIMARY KEY REFERENCES problem_versions(id) ON DELETE RESTRICT,
    body text NOT NULL,
    publication_status_id smallint NOT NULL DEFAULT 1,
    created_by bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT problem_editorials_body_check CHECK (btrim(body) <> ''),
    CONSTRAINT problem_editorials_publication_status_check CHECK (publication_status_id IN (1, 2, 3))
);
CREATE INDEX problem_editorials_creator_idx ON problem_editorials(created_by);
CREATE TABLE problem_test_cases (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    problem_version_id bigint NOT NULL REFERENCES problem_versions(id) ON DELETE RESTRICT,
    position integer NOT NULL,
    is_sample boolean NOT NULL DEFAULT false,
    input_file_id bigint NOT NULL REFERENCES stored_files(id) ON DELETE RESTRICT,
    expected_output_file_id bigint NOT NULL REFERENCES stored_files(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (problem_version_id, position),
    UNIQUE (problem_version_id, id),
    CONSTRAINT problem_test_cases_position_check CHECK (position > 0)
);
CREATE INDEX problem_test_cases_input_idx ON problem_test_cases(input_file_id);
CREATE INDEX problem_test_cases_output_idx ON problem_test_cases(expected_output_file_id);
COMMIT;
