BEGIN;
CREATE TABLE contests (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_by bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    title text NOT NULL,
    description text NOT NULL DEFAULT '',
    publication_status_id smallint NOT NULL DEFAULT 1,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    entry_password_hash text,
    penalty_minutes integer NOT NULL DEFAULT 20,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT contests_title_check CHECK (btrim(title) <> ''),
    CONSTRAINT contests_publication_status_check CHECK (publication_status_id IN (1, 2, 3)),
    CONSTRAINT contests_schedule_check CHECK (starts_at < ends_at),
    CONSTRAINT contests_password_check CHECK (btrim(entry_password_hash) <> ''),
    CONSTRAINT contests_penalty_check CHECK (penalty_minutes >= 0)
);
CREATE INDEX contests_publication_idx ON contests(publication_status_id, starts_at, id);
CREATE INDEX contests_creator_idx ON contests(created_by);
COMMIT;
