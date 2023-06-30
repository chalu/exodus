-- ====================================================
-- DQL
-- ====================================================

-- 2.a List all users who haven’t logged in, in the last year
SELECT *
FROM users
WHERE last_seen is NULL AND (CURRENT_TIMESTAMP - created_at) > INTERVAL '365 days'
		OR (CURRENT_TIMESTAMP - last_seen) > INTERVAL '365 days';


-- 2.b List all users who haven’t created any post.
SELECT u.id, u.username
FROM users AS u
WHERE u.id NOT IN (SELECT user_id from posts); 


-- 2.c Find a user by their username.
SELECT * FROM users WHERE username = 'value'; 

-- 2.d List all topics that don’t have any posts.
SELECT tp.id, tp.name
FROM topics AS tp
WHERE tp.id NOT IN (SELECT topic_id from posts); 

-- 2.e Find a topic by its name
SELECT tp.id, tp.name
FROM topics AS tp
WHERE tp.name = 'value';

-- 2.f List the latest 20 posts for a given topic
SELECT pt.id, pt.title
FROM posts AS pt
-- WHERE pt.topic_id = 'value'
WHERE pt.topic_id = (SELECT tp.id FROM topics tp WHERE tp.name = 'value')
ORDER BY pt.created_at DESC
LIMIT 20;

-- 2.g List the latest 20 posts made by a given user.
SELECT pt.id, pt.title
FROM posts AS pt
-- WHERE pt.user_id = 'value'
WHERE pt.user_id = (SELECT u.id FROM users u WHERE u.username = 'value')
ORDER BY pt.created_at DESC
LIMIT 20;

-- 2.h Find all posts that link to a specific URL, for moderation purposes. 
SELECT pt.id, pt.title
FROM posts AS pt
WHERE pt.url IS NOT NULL AND pt.url = 'value';

-- 2.i List all the top-level comments (those that don’t have a parent comment) for a given post.
SELECT *
FROM comments cmt
WHERE cmt.parent_id IS NULL AND cmt.post_id = 'value';

-- 2.j List all the direct children of a parent comment.
SELECT *
FROM comments cmt
WHERE cmt.parent_id = 'value';

-- 2.k List the latest 20 comments made by a given user. 
SELECT *
FROM comments cmt
-- WHERE cmt.user_id = 'value'
WHERE cmt.user_id = (SELECT u.id FROM users u WHERE u.username = 'value')
ORDER BY cmt.created_at DESC
LIMIT 20;

-- 2.i Compute the score of a post, defined as the difference between the number of upvotes and the number of downvotes
SELECT v.id,
	   v.upvotes,
       v.downvotes,
       COUNT(v.upvotes) - COUNT(abs(v.downvotes)) as score
FROM votes v;
