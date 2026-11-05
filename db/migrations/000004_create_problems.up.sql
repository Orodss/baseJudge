BEGIN;
CREATE TABLE problems (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_by bigint NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    publication_status_id smallint NOT NULL DEFAULT 1,
    difficulty_id smallint,
    current_version_id bigint,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT problems_publication_status_check CHECK (publication_status_id IN (1, 2, 3)),
    CONSTRAINT problems_difficulty_check CHECK (difficulty_id IN (1, 2, 3)),
    CONSTRAINT problems_published_check CHECK (
        publication_status_id <> 2 OR (current_version_id IS NOT NULL AND difficulty_id IS NOT NULL)
    )
);
CREATE INDEX problems_publication_idx ON problems(publication_status_id, id);
CREATE INDEX problems_creator_idx ON problems(created_by);
CREATE INDEX problems_current_version_idx ON problems(id, current_version_id);
COMMIT;
