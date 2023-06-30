# Udacious
Investigating, fixing and migrating a social news aggregator's relational database.

### Guideline 1: 

#### Features and specifications that Udacious needs to support its website and admin interface

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