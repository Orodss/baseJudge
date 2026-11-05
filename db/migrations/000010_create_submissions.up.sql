BEGIN;
CREATE TABLE submissions (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    problem_id bigint NOT NULL REFERENCES problems(id) ON DELETE RESTRICT,
    submitted_problem_version_id bigint NOT NULL,
    contest_id bigint,
    is_competitive boolean NOT NULL DEFAULT false,
    source_code text NOT NULL,
    requested_runtime_id bigint NOT NULL REFERENCES judge_runtimes(id) ON DELETE RESTRICT,
    submitted_at timestamptz NOT NULL,
    effective_judging_id bigint,
    UNIQUE (id, problem_id),
    CONSTRAINT submissions_version_fk FOREIGN KEY (problem_id, submitted_problem_version_id)
        REFERENCES problem_versions(problem_id, id) ON DELETE RESTRICT,
    CONSTRAINT submissions_contest_problem_fk FOREIGN KEY (contest_id, problem_id)
        REFERENCES contest_problems(contest_id, problem_id) ON DELETE RESTRICT,
    CONSTRAINT submissions_competitive_check CHECK (NOT is_competitive OR contest_id IS NOT NULL),
    CONSTRAINT submissions_source_check CHECK (btrim(source_code) <> '' AND octet_length(source_code) <= 262144)
);
CREATE INDEX submissions_user_idx ON submissions(user_id, submitted_at, id);
CREATE INDEX submissions_problem_idx ON submissions(problem_id, submitted_at, id);
CREATE INDEX submissions_contest_idx ON submissions(contest_id, problem_id);
CREATE INDEX submissions_runtime_idx ON submissions(requested_runtime_id);
CREATE INDEX submissions_version_idx ON submissions(problem_id, submitted_problem_version_id);
CREATE INDEX submissions_effective_idx ON submissions(id, effective_judging_id);
CREATE INDEX submissions_competition_idx ON submissions(contest_id, user_id, problem_id, submitted_at, id)
    WHERE is_competitive;
COMMIT;
