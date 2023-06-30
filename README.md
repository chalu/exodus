# Udacious
Investigating, fixing and migrating a social news aggregator's relational database.

### Investigate Exisiting Schema


[![ER disgram](./src/existing/udacious-old-erd.png)](https://dbdiagram.io/d/649ee3fa02bd1c4a5e4fe623)

1.  `bad_posts` is poorly structured to contain data that should ideally be in other tables and only then referenced from the `bad_posts` table. The way the username, upvotes and downvotes column is used is proof of this fact.
2.  `bad_posts` has very little data constraints and validation where it should.  Since the url column is optional, the title and text_content need to be not null, at least conditionally.
3.  The upvotes and downvotes columns in `bad_posts` being text will make filtering or aggregating on them very difficult .
4.  `bad_comments` seems to allow empty comments since the text_content column is not constrained with no null.
5.  Intuitively, comments are usually threaded, but `bad_comments` does not seem to indicate any support for that,
6.  Placing the actual text username of the author into `bad_posts` or `bad_comments` means the data can easily become inconsistent. At least it will be a nightmare to maintain data consistency and data integrity in the face of change. Ideally, username should only be updatable in a single place.

> **TODO :** Document how much data (row number) `bad_post` and `bad_comments` has.



### Create DDL For The New Schema

#### Guideline 1: Features and specifications that Udacious needs to support its website and admin interface

1.  Allow new users to register:
    -   Each username has to be unique
    -   Usernames can be composed of at most 25 characters
    -   Usernames can’t be empty
    -   We won’t worry about user passwords for this project
2.  Allow registered users to create new topics:
    -   Topic names have to be unique.
    -   The topic’s name is at most 30 characters
    -   The topic’s name can’t be empty   
    -   Topics can have an optional description of at most 500 characters.
3.  Allow registered users to create new posts on existing topics:
    -   Posts have a required title of at most 100 characters
    -   The title of a post can’t be empty.
    -   Posts should contain either a URL or a text content, but not both.
    -   If a topic gets deleted, all the posts associated with it should be automatically deleted too.
    -   If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user.
4.  Allow registered users to comment on existing posts:
    -   A comment’s text content can’t be empty.
    -   Contrary to the current linear comments, the new structure should allow comment threads at arbitrary levels.
    -   If a post gets deleted, all comments associated with it should be automatically deleted too.
    -   If the user who created the comment gets deleted, then the comment will remain, but it will become dissociated from that user.
    -   If a comment gets deleted, then all its descendants in the thread structure should be automatically deleted too.
5.  Make sure that a given user can only vote once on a given post:
    -   Hint: you can store the (up/down) value of the vote as the values 1 and -1 respectively.
    -   If the user who cast a vote gets deleted, then all their votes will remain, but will become dissociated from the user.
    -   If a post gets deleted, then all the votes for that post should be automatically deleted too.


### Create DQL For The New Schema

#### Guideline 1: Queries that Udacious needs to support its website and admin interface

1.  List all users who haven’t logged in in the last year.
2.  List all users who haven’t created any post.
3.  Find a user by their username.
4.  List all topics that don’t have any posts.
5.  Find a topic by its name.
6.  List the latest 20 posts for a given topic.
7.  List the latest 20 posts made by a given user.
8.  Find all posts that link to a specific URL, for moderation purposes. 
9.  List all the top-level comments (those that don’t have a parent comment) for a given post.
10.  List all the direct children of a parent comment.
11.  List the latest 20 comments made by a given user.
12.  Compute the score of a post, defined as the difference between the number of upvotes and the number of downvotes
