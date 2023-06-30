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
	ADD FOReign KEY ("topic_id") references "topics" ON DELETE CASCADE,
    ADD FOReign KEY ("user_id") references "users" ON DELETE SET NULL,
    ADD CONSTRAINT "non_empty_posttitle" CHECK (LENGTH(TRIM("title")) > 0),
    ADD CONSTRAINT "post_cnt_or_url" CHECK (
      NOT (
        LENGTH(TRIM("url")) > 0
      	AND LENGTH(TRIM("content")) > 0
      )
    ); 



