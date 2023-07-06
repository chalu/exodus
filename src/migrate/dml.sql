-- ====================================================
-- DML - Migrate the data into the new schema
-- ====================================================

-- 0. remove all data in destination tables and reset serial/sequential IDs
TRUNCATE TABLE "posts", "topics", "users", "comments", "votes"
RESTART IDENTITY;

