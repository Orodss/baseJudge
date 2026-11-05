BEGIN;
CREATE TABLE contest_problems (
    contest_id bigint NOT NULL REFERENCES contests(id) ON DELETE RESTRICT,
    problem_id bigint NOT NULL REFERENCES problems(id) ON DELETE RESTRICT,
    problem_version_id bigint NOT NULL,
    label text NOT NULL,
    position integer NOT NULL,
    PRIMARY KEY (contest_id, problem_id),
    UNIQUE (contest_id, label),
    UNIQUE (contest_id, position),
    CONSTRAINT contest_problems_version_fk FOREIGN KEY (problem_id, problem_version_id)
        REFERENCES problem_versions(problem_id, id) ON DELETE RESTRICT,
    CONSTRAINT contest_problems_label_check CHECK (btrim(label) <> ''),
    CONSTRAINT contest_problems_position_check CHECK (position > 0)
);
CREATE INDEX contest_problems_problem_idx ON contest_problems(problem_id, contest_id);
CREATE INDEX contest_problems_version_idx ON contest_problems(problem_id, problem_version_id);
CREATE TABLE contest_registrations (
    contest_id bigint NOT NULL REFERENCES contests(id) ON DELETE RESTRICT,
    user_id bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    registered_at timestamptz NOT NULL,
    PRIMARY KEY (contest_id, user_id)
);
CREATE INDEX contest_registrations_user_idx ON contest_registrations(user_id, contest_id);
CREATE TABLE contest_privileged_users (
    contest_id bigint NOT NULL REFERENCES contests(id) ON DELETE RESTRICT,
    user_id bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    granted_at timestamptz NOT NULL,
    PRIMARY KEY (contest_id, user_id)
);
CREATE INDEX contest_privileged_users_user_idx ON contest_privileged_users(user_id, contest_id);
COMMIT;
