-- ====================================================
-- DML - Migrate the data into the new schema
-- ====================================================

-- 0. remove all data in destination tables and reset serial/sequential IDs
TRUNCATE TABLE "posts", "topics", "users", "comments", "votes"
RESTART IDENTITY;

-- 1. migrate topics
-- TODO maybe change topics to title case and replace underscores with space
INSERT INTO "topics" ("name") SELECT DISTINCT topic FROM "bad_posts";


-- 2. migrate users
--
-- PS: There are lots of duplicate usernames e.g
-- SELECT COUNT(users) FROM (SELECT username AS users FROM bad_posts) t1 => 50000 users 
-- vs
-- SELECT COUNT(users) FROM (SELECT DISTINCT username AS users FROM bad_posts) t1 => 100 users
-- Also, 
-- SELECT unnest(string_to_array(upvotes, ',')) AS users VS SELECT DISTINCT unnest(string_to_array(upvotes, ',')) AS users
-- results in 249799 vs 1100 users while a smilimar query for downvotes results in 249911 vs 1100 users.
-- Comsequently, total users (across username, upvotes, downvotes in bad_posts and username in bad_comments)
-- sits at 11077
WITH allusers AS (
    SELECT username FROM bad_posts
    UNION SELECT unnest(string_to_array(upvotes, ',')) AS username FROM bad_posts
    UNION SELECT unnest(string_to_array(downvotes, ',')) AS username FROM bad_posts
    UNION SELECT username FROM bad_comments
)
INSERT INTO "users" ("username") SELECT DISTINCT username FROM allusers;

-- 3. migrate posts
--
-- PS: titles in the source table are 150 chars long
-- but this destination table only takes titles of 100 chars
WITH posts_data AS (
  SELECT bp.id AS post_id,
         usr.id AS user_id, 
         tpc.id AS topic_id, 
         LEFT(bp.title, 100) AS title, 
         bp.url, 
         bp.text_content 
  FROM bad_posts bp
  JOIN users usr ON bp.username = usr.username
  JOIN topics tpc ON bp.topic = tpc.name
  ORDER BY post_id ASC
)
INSERT INTO "posts" ("user_id", "topic_id", "title", "url", "content")
SELECT user_id, topic_id, title, url, text_content
FROM posts_data;


-- To compare and validate "posts" migration, run:
-- this query on the old schema/data
SELECT bp.id, bp.username, bp.topic, bp.title 
FROM bad_posts bp 
ORDER BY id LIMIT 10;

-- vs this query on the new schema/data

SELECT pts.id, usr.username, tpc.name AS topic, pts.title
FROM posts pts
JOIN users usr ON usr.id = pts.user_id
JOIN topics tpc ON tpc.id = pts.topic_id
ORDER BY pts.id ASC
LIMIT 10;

