BEGIN;
CREATE TABLE judgings (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    submission_id bigint NOT NULL,
    attempt_number integer NOT NULL,
    problem_id bigint NOT NULL,
    problem_version_id bigint NOT NULL,
    runtime_id bigint NOT NULL REFERENCES judge_runtimes(id) ON DELETE RESTRICT,
    rejudge_batch_id bigint REFERENCES rejudge_batches(id) ON DELETE RESTRICT,
    status_id smallint NOT NULL DEFAULT 1,
    verdict_id smallint,
    queued_at timestamptz NOT NULL DEFAULT now(),
    started_at timestamptz,
    finished_at timestamptz,
    worker_key text,
    lease_token uuid,
    lease_expires_at timestamptz,
    compile_log_file_id bigint REFERENCES stored_files(id) ON DELETE RESTRICT,
    infrastructure_error text,
    UNIQUE (submission_id, attempt_number),
    UNIQUE (submission_id, id),
    UNIQUE (id, problem_version_id),
    UNIQUE (rejudge_batch_id, submission_id, id),
    CONSTRAINT judgings_submission_fk FOREIGN KEY (submission_id, problem_id)
        REFERENCES submissions(id, problem_id) ON DELETE RESTRICT,
    CONSTRAINT judgings_version_fk FOREIGN KEY (problem_id, problem_version_id)
        REFERENCES problem_versions(problem_id, id) ON DELETE RESTRICT,
    CONSTRAINT judgings_attempt_check CHECK (attempt_number > 0),
    CONSTRAINT judgings_status_check CHECK (status_id IN (1, 2, 3, 4)),
    CONSTRAINT judgings_verdict_check CHECK (verdict_id IN (1, 2, 3, 4, 5, 6)),
    CONSTRAINT judgings_worker_check CHECK (btrim(worker_key) <> ''),
    CONSTRAINT judgings_error_check CHECK (
        btrim(infrastructure_error) <> '' AND octet_length(infrastructure_error) <= 8192
    ),
    CONSTRAINT judgings_start_check CHECK (
        started_at IS NULL OR (worker_key IS NOT NULL AND started_at >= queued_at)
    ),
    CONSTRAINT judgings_finish_check CHECK (finished_at >= queued_at AND finished_at >= started_at),
    CONSTRAINT judgings_lease_check CHECK (lease_expires_at > started_at),
    CONSTRAINT judgings_lifecycle_check CHECK (
        (status_id = 1 AND verdict_id IS NULL AND started_at IS NULL AND finished_at IS NULL
         AND worker_key IS NULL AND lease_token IS NULL AND lease_expires_at IS NULL AND infrastructure_error IS NULL)
        OR (status_id = 2 AND started_at IS NOT NULL AND worker_key IS NOT NULL
         AND lease_token IS NOT NULL AND lease_expires_at IS NOT NULL AND verdict_id IS NULL
         AND finished_at IS NULL AND infrastructure_error IS NULL)
        OR (status_id = 3 AND started_at IS NOT NULL AND finished_at IS NOT NULL AND verdict_id IS NOT NULL
         AND worker_key IS NOT NULL AND lease_token IS NULL AND lease_expires_at IS NULL AND infrastructure_error IS NULL)
        OR (status_id = 4 AND finished_at IS NOT NULL AND infrastructure_error IS NOT NULL
         AND verdict_id IS NULL AND lease_token IS NULL AND lease_expires_at IS NULL)
    )
);
CREATE UNIQUE INDEX judgings_one_active_idx ON judgings(submission_id) WHERE status_id IN (1, 2);
CREATE INDEX judgings_queue_idx ON judgings(queued_at, id) WHERE status_id = 1;
CREATE INDEX judgings_expiry_idx ON judgings(lease_expires_at) WHERE status_id = 2;
CREATE INDEX judgings_version_idx ON judgings(problem_id, problem_version_id);
CREATE INDEX judgings_runtime_idx ON judgings(runtime_id);
CREATE INDEX judgings_compile_log_idx ON judgings(compile_log_file_id);
CREATE INDEX judgings_submission_idx ON judgings(submission_id, problem_id);
ALTER TABLE submissions ADD CONSTRAINT submissions_effective_judging_fk
    FOREIGN KEY (id, effective_judging_id) REFERENCES judgings(submission_id, id) ON DELETE RESTRICT;
COMMIT;
