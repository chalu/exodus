-- ====================================================
-- DML - Migrate the data into the new schema
-- ====================================================

-- 1. migrate topics

INSERT INTO "topics" ("name")  SELECT DISTINCT topic FROM "bad_posts";