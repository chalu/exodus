# Udacious
Investigating, fixing and migrating a social news aggregator's relational database.

### Investigate Exisiting Schema :writing_hand:


![ER disgram](./src/existing/udacious-existing-erd.png)

1.  `bad_posts` is poorly structured to contain data that should ideally be in other tables and only then referenced from the `bad_posts` table. The way the username, upvotes and downvotes column is used is proof of this fact.
2.  `bad_posts` has very little data constraints and validation where it should.  Since the url column is optional, the title and text_content need to be not null, at least conditionally.
3.  The upvotes and downvotes columns in `bad_posts` being text will make filtering or aggregating on them very difficult .
4.  `bad_comments` seems to allow empty comments since the text_content column is not constrained with no null.
5.  Intuitively, comments are usually threaded, but `bad_comments` does not seem to indicate any support for that,
6.  Placing the actual text username of the author into `bad_posts` or `bad_comments` means the data can easily become inconsistent. At least it will be a nightmare to maintain data consistency and data integrity in the face of change. Ideally, username should only be updatable in a single place.

> **TODO :** Document how much data (row number) `bad_post` and `bad_comments` has.


### Proposed New Schema

![ER disgram](./src/proposed/udacious-proposed-erd.png)

> Summarized below :point_down: Full details are [:point_right: in here](./src/proposed/) 

#### Guideline 1: Features and specifications that Udacious needs to support its website and admin interface :sunglasses: :nerd_face:

1.  Allow new users to register
2.  Allow registered users to create new topics
3.  Allow registered users to create new posts on existing topics
4.  Allow registered users to comment on existing posts
5.  Make sure that a given user can only vote once on a given post


#### Guideline 2: Queries that Udacious needs to support its website and admin interface :sunglasses: :nerd_face:

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


### TODO: Migrate Existing Data To New Schema [`DEV / LOCAL`] :thumbsup:


### TODO: Migrate Existing Data To New Schema [`PROD / LIVE`] :crossed_fingers: :muscle:
