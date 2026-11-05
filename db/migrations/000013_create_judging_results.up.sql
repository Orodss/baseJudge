BEGIN;
CREATE TABLE judging_test_results (
    judging_id bigint NOT NULL,
    test_case_id bigint NOT NULL,
    problem_version_id bigint NOT NULL,
    verdict_id smallint NOT NULL,
    runtime_ms bigint,
    memory_bytes bigint,
    output_file_id bigint REFERENCES stored_files(id) ON DELETE RESTRICT,
    diagnostic_file_id bigint REFERENCES stored_files(id) ON DELETE RESTRICT,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (judging_id, test_case_id),
    CONSTRAINT judging_test_results_judging_fk FOREIGN KEY (judging_id, problem_version_id)
        REFERENCES judgings(id, problem_version_id) ON DELETE RESTRICT,
    CONSTRAINT judging_test_results_test_fk FOREIGN KEY (problem_version_id, test_case_id)
        REFERENCES problem_test_cases(problem_version_id, id) ON DELETE RESTRICT,
    CONSTRAINT judging_test_results_verdict_check CHECK (verdict_id IN (1, 2, 3, 4, 5)),
    CONSTRAINT judging_test_results_runtime_check CHECK (runtime_ms >= 0),
    CONSTRAINT judging_test_results_memory_check CHECK (memory_bytes >= 0)
);
CREATE INDEX judging_test_results_test_idx ON judging_test_results(problem_version_id, test_case_id);
CREATE INDEX judging_test_results_judging_idx ON judging_test_results(judging_id, problem_version_id);
CREATE INDEX judging_test_results_output_idx ON judging_test_results(output_file_id);
CREATE INDEX judging_test_results_diagnostic_idx ON judging_test_results(diagnostic_file_id);
CREATE TABLE rejudge_items (
    batch_id bigint NOT NULL REFERENCES rejudge_batches(id) ON DELETE RESTRICT,
    submission_id bigint NOT NULL REFERENCES submissions(id) ON DELETE RESTRICT,
    baseline_judging_id bigint,
    candidate_judging_id bigint,
    PRIMARY KEY (batch_id, submission_id),
    CONSTRAINT rejudge_items_baseline_fk FOREIGN KEY (submission_id, baseline_judging_id)
        REFERENCES judgings(submission_id, id) ON DELETE RESTRICT,
    CONSTRAINT rejudge_items_candidate_fk FOREIGN KEY (batch_id, submission_id, candidate_judging_id)
        REFERENCES judgings(rejudge_batch_id, submission_id, id) ON DELETE RESTRICT
);
CREATE INDEX rejudge_items_baseline_idx ON rejudge_items(submission_id, baseline_judging_id);
CREATE INDEX rejudge_items_candidate_idx ON rejudge_items(batch_id, submission_id, candidate_judging_id);
COMMIT;
