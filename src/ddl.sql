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