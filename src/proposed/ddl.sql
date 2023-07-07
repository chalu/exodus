-- ====================================================
-- DDL
-- ====================================================

-- users
DROP TABLE IF EXISTS "users";
CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(25) UNIQUE NOT NULL,
  "last_seen" TIMESTAMP WITH TIME ZONE,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL default CURRENT_TIMESTAMP
);

ALTER TABLE "users" 
	ADD CONSTRAINT "non_empty_username" CHECK (LENGTH(TRIM("username")) > 0);

-- topics
DROP TABLE IF EXISTS "topics";
CREATE TABLE "topics" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(30) UNIQUE NOT NULL,
  "description" VARCHAR(500),
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL default CURRENT_TIMESTAMP
);

ALTER TABLE "topics" 
	ADD CONSTRAINT "non_empty_topicname" CHECK (LENGTH(TRIM("name")) > 0);

-- posts
DROP TABLE IF EXISTS "posts";
CREATE TABLE "posts" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER,
  "topic_id" INTEGER NOT NULL,
  "title" VARCHAR(100) NOT NULL,
  "url" TEXT,
  "content" TEXT,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL default CURRENT_TIMESTAMP 
);

ALTER TABLE "posts" 
	ADD FOREIGN KEY ("topic_id") references "topics" ON DELETE CASCADE,
    ADD FOREIGN KEY ("user_id") references "users" ON DELETE SET NULL,
    ADD CONSTRAINT "non_empty_posttitle" CHECK (LENGTH(TRIM("title")) > 0),
    ADD CONSTRAINT "post_cnt_or_url" CHECK (
      NOT (
        LENGTH(TRIM("url")) > 0
      	AND LENGTH(TRIM("content")) > 0
      )
    ); 
    
CREATE INDEX "find_posts_by_title" ON "posts" (
  LOWER("title") VARCHAR_PATTERN_OPS
);
CREATE INDEX "find_posts_by_url" ON "posts" (url);


-- comments
DROP TABLE IF EXISTS "comments";
CREATE TABLE "comments" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER,
  "post_id" INTEGER NOT NULL,
  "parent_id" INTEGER,
  "content" TEXT NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL default CURRENT_TIMESTAMP
);

ALTER TABLE "comments"
	ADD FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL,
    ADD FOREIGN KEY ("post_id") REFERENCES "posts" ON DELETE CASCADE,
    ADD FOREIGN KEY ("parent_id") REFERENCES "comments" ON DELETE CASCADE;
    
CREATE INDEX "find_parent_comments" ON "comments" (parent_id);
    

-- votes
DROP TABLE IF EXISTS "votes";
CREATE TABLE "votes" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INTEGER,
  "post_id" INTEGER NOT NULL,
  "vote" SMALLINT,
  "created_at" TIMESTAMP WITH TIME ZONE NOT NULL default CURRENT_TIMESTAMP
);

ALTER TABLE "votes"
	ADD UNIQUE ("user_id", "post_id"),
	ADD FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL,
    ADD FOREIGN KEY ("post_id") REFERENCES "posts" ON DELETE CASCADE;

CREATE INDEX "find_votes_by_voter_on_post" ON "votes" (user_id, post_id);