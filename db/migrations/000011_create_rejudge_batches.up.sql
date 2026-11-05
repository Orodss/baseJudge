BEGIN;
CREATE TABLE rejudge_batches (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    requested_by bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    reason text NOT NULL,
    state_id smallint NOT NULL DEFAULT 1,
    created_at timestamptz NOT NULL DEFAULT now(),
    decided_at timestamptz,
    decided_by bigint REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT rejudge_batches_reason_check CHECK (btrim(reason) <> ''),
    CONSTRAINT rejudge_batches_state_check CHECK (state_id IN (1, 2, 3, 4)),
    CONSTRAINT rejudge_batches_decision_check CHECK (
        (state_id IN (1, 2) AND decided_at IS NULL AND decided_by IS NULL)
        OR (state_id IN (3, 4) AND decided_at IS NOT NULL AND decided_by IS NOT NULL)
    ),
    CONSTRAINT rejudge_batches_time_check CHECK (decided_at >= created_at)
);
CREATE INDEX rejudge_batches_state_idx ON rejudge_batches(state_id, created_at, id);
CREATE INDEX rejudge_batches_requester_idx ON rejudge_batches(requested_by);
CREATE INDEX rejudge_batches_decider_idx ON rejudge_batches(decided_by);
COMMIT;
