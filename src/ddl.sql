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

