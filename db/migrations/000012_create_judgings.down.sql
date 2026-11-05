BEGIN;
ALTER TABLE submissions DROP CONSTRAINT submissions_effective_judging_fk;
DROP TABLE judgings;
COMMIT;
