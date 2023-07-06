-- ====================================================
-- DML - Migrate the data into the new schema
-- ====================================================

-- 0. remove all data in destination tables and reset serial/sequential IDs
TRUNCATE TABLE "posts", "topics", "users", "comments", "votes"
RESTART IDENTITY;

-- 1. migrate topics
-- TODO maybe change topics to title case and replace underscores with space
INSERT INTO "topics" ("name") SELECT DISTINCT topic FROM "bad_posts";

