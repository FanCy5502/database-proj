DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS forums;
DROP TABLE IF EXISTS moderators;
CREATE TABLE user (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    nickname VARCHAR(50)
);
CREATE TABLE post (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    author_id INTEGER NOT NULL,
    forum_id INTEGER NOT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    liked INTEGER DEFAULT 0,
    commented INTEGER DEFAULT 0,
    FOREIGN KEY (author_id) REFERENCES user (id),
    FOREIGN KEY (forum_id) REFERENCES forums(forum_id)
);
CREATE TABLE forums (
    forum_id INTEGER PRIMARY KEY  AUTOINCREMENT,
    forum_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE applications (
    application_id INTEGER PRIMARY KEY  AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    forum_id INTEGER NOT NULL,
    status INTEGER,
    FOREIGN KEY (user_id) REFERENCES user (id),
    FOREIGN KEY (forum_id) REFERENCES forums(forum_id)
);
CREATE TABLE moderators (
    moderator_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    forum_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user (id),
    FOREIGN KEY (forum_id) REFERENCES forums (forum_id)
);
CREATE TABLE comment (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    parent_post_id INT,
    body TEXT NOT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES  post(id),
    FOREIGN KEY (user_id) REFERENCES user (id)
);


INSERT INTO forums(forum_name, description)
VALUES ('学业', '有关学习'),
       ('选课','有关选课'),
       ('娱乐', '有关娱乐'),
       ('树洞', '有关树洞');
INSERT INTO user(username, password, nickname)
VALUES ('123', '123', '123'),
       ('abc', 'abc', 'abc'),
       ('feibo','123', 'feibo'),
       ('damdam','123','damdam'),
       ('tutu', '123', 'tutu');
INSERT INTO post(author_id, forum_id, title, body)
VALUES ('1', '1', 'abc', 'abcdefg'),
       ('1', '2', '123', '1234567'),
       ('2', '3', 'asdsdasd', 'asdasdfasdfasdfas'),
       ('3','4','asdafadf','chaoshidamdam'),
       ('4','4','asdafadfadf','chaoshitutu'),
       ('5','4','sadafsdf','chaoshifeibo');
INSERT INTO comment(post_id, user_id, body)
VALUES ('6','4','nihao'),
       ('5','3','chaoshitutu'),
       ('1', '2', 'sadsafasfasdaxxcv'),
       ('2','4', 'sdassdfascdsaasadsf'),
       ('2','4','dasdasdzcx'),
       ('4','3','dfasddasfasd');
INSERT INTO comment(post_id, user_id, parent_post_id, body)
VALUES ('6','5','1','pa'),
       ('3','2','1','dasddasf'),
       ('4','2','2','sdfadsfasfda');

