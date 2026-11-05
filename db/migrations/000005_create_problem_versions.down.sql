BEGIN;
ALTER TABLE problems DROP CONSTRAINT problems_current_version_fk;
DROP TABLE problem_versions;
COMMIT;
