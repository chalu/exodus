-- ====================================================
-- DML - Migrate the data into the new schema
-- ====================================================

-- 0. remove all data in destination tables and reset serial/sequential IDs
TRUNCATE TABLE "posts", "topics", "users", "comments", "votes" RESTART IDENTITY;

-- 1. migrate topics
-- TODO maybe change topics to title case and replace underscores with space
INSERT INTO "topics" ("name") SELECT DISTINCT topic FROM "bad_posts";

-- 2. migrate users
-- PS: There are lots of duplicate usernames e.g
-- SELECT COUNT(users) FROM (SELECT username AS users FROM bad_posts) t1 => 50000 users 
-- vs
-- SELECT COUNT(users) FROM (SELECT DISTINCT username AS users FROM bad_posts) t1 => 100 users
-- Also, SELECT unnest(string_to_array(upvotes, ',')) AS users VS SELECT DISTINCT unnest(string_to_array(upvotes, ',')) AS users
-- results in 249799 vs 1100 users while a smilimar query for downvotes results in 249911 vs 1100 users for downvotes.
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

-- 4. migrate comments
WITH comments_data AS (
  SELECT bp.id AS post_id,
         usr.id AS user_id,
  		 bc.id AS comment_id,
         bc.text_content AS text_content
  FROM bad_posts bp
  JOIN bad_comments bc ON bp.id = bc.post_id
  JOIN users usr ON bc.username = usr.username
  ORDER BY comment_id ASC
)
INSERT INTO "comments" ("user_id", "post_id", "content")
SELECT user_id, post_id, text_content
FROM comments_data;

-- To compare and validate "comments" migration, run:
-- this query on the old schema/data
SELECT bc.id, 
       bc.post_id, 
       bc.username AS "user", 
       LEFT(bp.title, 50) AS post_title, 
       LEFT(bc.text_content, 50) AS "comment"
FROM bad_comments bc
JOIN bad_posts bp ON bp.id = bc.post_id
ORDER BY id LIMIT 10;

-- vs this query on the new schema/data

SELECT cmts.id, 
       cmts.post_id, 
       usr.username AS "user", 
       LEFT(pts.title, 50) AS post_title,
       LEFT(cmts.content, 50) AS "comment"
FROM posts pts
JOIN "comments" cmts ON pts.id = cmts.post_id
JOIN users usr ON usr.id = cmts.user_id
ORDER BY cmts.id ASC
LIMIT 10;


-- 5. migrate votes 
WITH upvoters AS (
  SELECT DISTINCT unnest(string_to_array(upvotes, ',')) AS voter FROM bad_posts
),
downvoters AS (
  SELECT DISTINCT unnest(string_to_array(downvotes, ',')) AS voter, "id" AS post_id FROM bad_posts
),
upvotes_on_posts AS (
  SELECT bp.id AS bp_id, pst.id AS post_id, pst.title AS post, usr.id AS user_id, usr.username 
  FROM users usr
  JOIN bad_posts bp 
    ON usr.username IN (SELECT voter FROM upvoters)
    -- below will filter out downvotes
    AND bp.id NOT IN (SELECT post_id FROM downvoters)
  JOIN posts pst 
    ON pst.title = LEFT(bp.title, 100)
)
INSERT INTO "votes" ("user_id", "post_id", "vote")
  SELECT user_id, post_id, '1'::numeric as vote FROM upvotes_on_posts;
-- above query inserted 4,991,800 rows in 1 min 42 secs
  
WITH downvoters AS (
  SELECT DISTINCT unnest(string_to_array(downvotes, ',')) AS voter, "id" AS post_id FROM bad_posts
),
downvotes_on_posts AS (
  SELECT bp.id AS bp_id, pst.id AS post_id, pst.title AS post, usr.id AS user_id, usr.username 
  FROM bad_posts bp
  JOIN posts pst ON pst.title = LEFT(bp.title, 100)
  JOIN users usr  
    ON usr.username IN (SELECT voter FROM downvoters)
    -- filter out existing vote on a specifc post by a given user
    AND (SELECT COUNT("id") FROM votes WHERE user_id = usr.id AND post_id = pst.id LIMIT 1) = 0
)
INSERT INTO "votes" ("user_id", "post_id", "vote")
  SELECT user_id, post_id, '-1'::numeric as vote FROM downvotes_on_posts;
-- above query inserted 50,008,200 rows in 23 mins
-- making a total of 55,000,000 rows in the votes table