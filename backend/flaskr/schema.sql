DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Post;
DROP TABLE IF EXISTS Comment;
DROP TABLE IF EXISTS Report;
DROP TABLE IF EXISTS Forum;
DROP TABLE IF EXISTS Apply;

DROP TABLE IF EXISTS user_apply;
DROP TABLE IF EXISTS take;
DROP TABLE IF EXISTS release_post;
DROP TABLE IF EXISTS browse;
DROP TABLE IF EXISTS release_comment;
DROP TABLE IF EXISTS like_comment;
DROP TABLE IF EXISTS release_report;
DROP TABLE IF EXISTS com_post;
DROP TABLE IF EXISTS parent;
DROP TABLE IF EXISTS report_post;
DROP TABLE IF EXISTS report_comment;
DROP TABLE IF EXISTS post_forum;
DROP TABLE IF EXISTS report_post;
DROP TABLE IF EXISTS manage_forum;

CREATE TABLE User (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    grade INTEGER DEFAULT 0,
    major VARCHAR(50) DEFAULT '新生院',
    category VARCHAR NOT NULL CHECK (category IN ('admin', 'moderator', 'user')) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE Course (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT ,
    course_name VARCHAR NOT NULL,
    dept VARCHAR NOT NULL,
    teacher_name VARCHAR NOT NULL
);
CREATE TABLE Post (
    post_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    liked INTEGER DEFAULT 0,
    commented INTEGER DEFAULT 0,
    post_status INTEGER DEFAULT 1        --ENUM('not active':0, 'active':1)
);
CREATE TABLE Comment (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    body TEXT NOT NULL
);
CREATE TABLE Report(
    report_id INTEGER PRIMARY KEY AUTOINCREMENT,
    reason TEXT NOT NULL,
    report_status INTEGER DEFAULT 0        -- ENUM('pending':0,'resolved':1,'rejected':2)
);
CREATE TABLE Forum (
    forum_id INTEGER PRIMARY KEY  AUTOINCREMENT,
    forum_name VARCHAR(100) NOT NULL UNIQUE ,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Apply(
    apply_id INTEGER PRIMARY KEY  AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE ,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    apply_status INTEGER DEFAULT 0         --ENUM('pending':0,'resolved':1,'rejected':2)
);

CREATE TABLE user_apply(
    user_id INTEGER,
    apply_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (apply_id) REFERENCES Apply(apply_id),
    PRIMARY KEY (user_id, apply_id)
);

CREATE TABLE take (
    user_id INTEGER,
    course_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    PRIMARY KEY (user_id, course_id)
);
CREATE TABLE release_post (
    post_id INTEGER,
    user_id INTEGER,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    PRIMARY KEY (post_id, user_id)
);
CREATE TABLE browse (
    post_id INTEGER ,
    user_id INTEGER ,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration INTEGER DEFAULT 0,
    is_like INTEGER DEFAULT 0,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    PRIMARY KEY (post_id, user_id)
);
CREATE TABLE release_comment (
    comment_id INTEGER,
    user_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comment_id) REFERENCES Comments(comment_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    PRIMARY KEY (comment_id, user_id)
);
CREATE TABLE like_comment (
    comment_id INTEGER,
    user_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (comment_id) REFERENCES Comments(comment_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    PRIMARY KEY (comment_id, user_id)
);
CREATE TABLE release_report (
    report_id INTEGER,
    user_id INTEGER,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (report_id) REFERENCES Reports(report_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    PRIMARY KEY (report_id, user_id)
);
CREATE TABLE com_post (
    comment_id INTEGER,
    post_id INTEGER,
    FOREIGN KEY (comment_id) REFERENCES Comments(comment_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    PRIMARY KEY (comment_id, post_id)
);
CREATE TABLE parent (
    parent_comment_id INTEGER,
    comment_id INTEGER ,
    FOREIGN KEY (parent_comment_id) REFERENCES Comments(comment_id),
    FOREIGN KEY (comment_id) REFERENCES Comments(comment_id),
    PRIMARY KEY (parent_comment_id, comment_id)
);
CREATE TABLE report_post (
    report_id INTEGER,
    post_id INTEGER ,
    FOREIGN KEY (report_id) REFERENCES Reports(report_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    PRIMARY KEY (report_id, post_id)
);
CREATE TABLE report_comment (
    report_id INTEGER,
    comment_id INTEGER ,
    FOREIGN KEY (report_id) REFERENCES Reports(report_id),
    FOREIGN KEY (comment_id) REFERENCES Comments(comment_id),
    PRIMARY KEY (report_id, comment_id)
);
CREATE TABLE post_forum (
    post_id INTEGER,
    forum_id INTEGER,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (forum_id) REFERENCES Forums(forum_id),
    PRIMARY KEY (post_id, forum_id)
);
CREATE TABLE manage_forum (
    forum_id INTEGER,
    user_id INTEGER,
    FOREIGN KEY (forum_id) REFERENCES Forums(forum_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    PRIMARY KEY (forum_id, user_id)
);

INSERT INTO User (username, password, nickname, grade, major, category) VALUES
('admin', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', 'admin', 0, 'Not applicable', 'admin');

INSERT INTO User (username, password, nickname, grade, major) VALUES
('zhangsan', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '张三', 2021, '计算机科学与技术'),
('lisi', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '李四', 2022, '电子信息工程'),
('wangwu', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '王五', 2023, '机械工程'),
('zhaoliu', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '赵六', 2024, '土木工程'),
('chenqi', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '陈七', 2021, '生物工程'),
('liubing', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '刘兵', 2023, '物理学'),
('wushuo', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '吴硕', 2022, '化学'),
('yangyi', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '杨易', 2023, '数学与应用数学'),
('sunwei', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '孙伟', 2024, '法学'),
('houjie', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '侯杰', 2021, '医学'),
('guangming', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '光明', 2022, '金融学'),
('maofeng', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '毛峰', 2023, '会计学'),
('tianlong', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '田龙', 2024, '市场营销'),
('huangqiang', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '黄强', 2021, '人力资源管理'),
('caohao', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '曹浩', 2022, '广告学'),
('lianqi', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '连琪', 2023, '艺术设计'),
('xiaoqiang', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '小强', 2024, '环境科学'),
('chenghui', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '程辉', 2021, '电子商务'),
('liuwei', 'a665a4cf3e9bb70fc8d6f5fc8c6bb9d4b9ed429ab017b39d36086be19379b4a4', '刘伟', 2022, '软件工程');



INSERT INTO Course (course_name, dept, teacher_name) VALUES
('计算机网络', '计算机科学与技术', '张老师'),
('数据库系统', '计算机科学与技术', '李老师'),
('操作系统', '计算机科学与技术', '王老师'),
('数字电路', '电子信息工程', '赵老师'),
('信号与系统', '电子信息工程', '陈老师'),
('工程力学', '机械工程', '刘老师'),
('结构力学', '机械工程', '吴老师'),
('土木工程基础', '土木工程', '杨老师'),
('钢筋混凝土', '土木工程', '孙老师'),
('生物化学', '生物工程', '侯老师'),
('生物医学工程', '生物工程', '光老师'),
('物理实验', '物理学', '毛老师'),
('量子力学', '物理学', '田老师'),
('有机化学', '化学', '黄老师'),
('化学反应工程', '化学', '连老师'),
('高等数学', '数学与应用数学', '小强老师'),
('概率论与数理统计', '数学与应用数学', '程老师'),
('法学导论', '法学', '刘老师'),
('宪法学', '法学', '李老师'),
('医学基础', '医学', '魏老师'),
('临床医学', '医学', '郭老师'),
('财务管理', '金融学', '朱老师'),
('会计学原理', '会计学', '吴老师'),
('市场营销学', '市场营销', '吴老师'),
('广告学概论', '广告学', '陈老师'),
('艺术设计基础', '艺术设计', '赵老师'),
('环境科学导论', '环境科学', '刘老师'),
('环境工程学', '环境科学', '张老师'),
('电子商务基础', '电子商务', '赵老师');


INSERT INTO Post (title, body) VALUES
('如何学习计算机网络', '本文将介绍如何高效学习计算机网络的相关知识。'),
('数据库系统课程心得', '数据库系统是每个计算机专业学生必修的课程，以下是我的学习心得。'),
('操作系统基础知识', '本文简要介绍操作系统的基本概念和原理。'),
('数字电路设计的要点', '数字电路的设计在电子工程中非常重要，以下是我对其的理解。'),
('信号与系统的重要性', '信号与系统是电子信息工程的重要课程，掌握其基础是十分必要的。'),
('机械工程基础', '机械工程专业的基础课程涉及很多核心技术和原理，以下是我的一些想法。'),
('结构力学难点解析', '结构力学的学习过程中存在许多难点，本文给出了一些解决思路。'),
('土木工程基础课程总结', '土木工程基础课程不仅仅是理论学习，实践部分也非常重要。'),
('钢筋混凝土设计原则', '钢筋混凝土的设计是土木工程中的核心内容之一。'),
('生物医学工程的未来发展', '生物医学工程将对未来医疗产生深远的影响。'),
('物理学研究的最新进展', '物理学的研究不断推进，本文总结了一些最新的研究成果。'),
('有机化学实验分享', '有机化学实验是化学专业的基础课程，实践很重要。'),
('量子力学与现代物理', '量子力学是现代物理学的重要组成部分。'),
('有机化学的经典案例', '有机化学实验中有许多经典案例值得大家学习。'),
('环境科学的重要性', '环境科学的研究对我们的生活和社会至关重要。'),
('环保意识的培养', '环保意识是当今社会每个人都需要培养的素质。'),
('艺术设计的发展趋势', '艺术设计的未来发展方向充满了创新和可能性。'),
('广告学的应用技巧', '广告学不仅涉及理论，更多的是应用技术。'),
('财务管理的基础理论', '财务管理的核心理论是每个管理人员必须掌握的。'),
('会计学的难点与对策', '会计学在实践中会遇到很多难题，本文列出了几点应对策略。'),
('电子商务发展前景', '电子商务是现代经济的一个重要组成部分，前景广阔。'),
('互联网营销的创新', '互联网营销的创新为企业提供了更多的市场机会。'),
('医学基础课程的理解', '医学基础课程帮助我们为未来的医学事业打下坚实的基础。'),
('临床医学的实践意义', '临床医学不仅是理论的学习，更重要的是实践能力的培养。'),
('市场营销的基本策略', '市场营销策略对于企业发展至关重要。'),
('广告学实践经验', '广告学的实践经验是学习该课程的重要组成部分。'),
('艺术设计的跨界应用', '艺术设计在现代社会的各个领域都有广泛应用。'),
('环境科学技术发展', '环境科学技术的进展将为我们带来更加可持续的未来。'),
('电商与消费者行为', '电商的快速发展改变了消费者的行为模式。'),
('数据库的优化方法', '数据库的优化方法有很多，本文总结了几种常用的技巧。'),
('操作系统的最新发展', '操作系统技术的更新换代不断推动计算机技术的发展。');


INSERT INTO Comment (body) VALUES
('这篇文章写得很好，受益匪浅！'),
('我有一些不同的看法，能否进一步说明？'),
('非常有帮助，我会按照这个方法进行学习。'),
('我觉得这个方法还有改进的空间，可以再深入探讨一下。'),
('感谢分享，学到了很多新东西！'),
('操作系统是一个非常有挑战的课程，需要多加练习。'),
('对于数据库的优化，我有一些补充意见，感谢楼主的分享。'),
('这篇文章的思路很清晰，给了我很多启发。'),
('我认为信号与系统的内容对于我后续学习非常有帮助。'),
('有很多具体例子可以更好地帮助理解，希望楼主能补充。'),
('这篇文章的结构很好，逻辑清晰，简洁明了。'),
('学习的过程中，很多地方需要更多实践来加深理解。'),
('量子力学的内容有些抽象，建议可以提供更多的例子。'),
('环境科学是当今社会非常重要的学科，希望大家能重视起来。'),
('大家有没有学习经验分享，我在学艺术设计的时候遇到了一些困难。'),
('互联网营销的实战经验非常重要，希望能有更多的案例分享。'),
('我觉得市场营销的理论非常有趣，可以尝试在实际工作中应用。'),
('医学课程的难度相对较大，希望大家可以多交流经验。'),
('会计学的实务操作非常重要，学习过程中不能忽视。'),
('广告学的实践案例可以多一些，帮助理解理论。'),
('有机化学实验非常有趣，但实验操作有时会遇到一些困难。'),
('我对于钢筋混凝土的设计有一些问题，大家可以一起讨论。'),
('这篇文章的观点很有见地，提出了许多值得思考的观点。'),
('希望能有更多的电子商务案例分析，帮助理解市场操作。'),
('我觉得艺术设计的理论可以结合更多实际案例来讨论。'),
('量子力学的实验部分我觉得理解比较难，希望有更多详细讲解。'),
('操作系统的内容比较难，尤其是内存管理部分。'),
('环境保护是我们每个人都应该关心的问题。'),
('在学习化学课程时，很多实验操作需要多次练习才能熟练掌握。'),
('电商平台的消费者行为分析对电商策略制定非常有帮助。'),
('我觉得数字电路的基础知识对于后续学习非常重要。'),
('医学知识是一个庞大的领域，需要不断学习和实践。'),
('广告学的实际应用非常多，能够在实践中获得更多的经验。');

INSERT INTO Report (reason) VALUES
('系统存在漏洞，影响用户体验'),
('有用户发布了不当内容'),
('论坛中存在不良信息'),
('有用户侵犯了他人权益'),
('存在虚假广告'),
('内容不符合社区规范'),
('发布者恶意刷屏'),
('论坛评论区有恶意攻击'),
('发布的内容涉及违法行为'),
('有用户恶意评论他人');


INSERT INTO Forum (forum_name, description) VALUES
('技术讨论区', '这是一个关于技术相关话题的讨论区'),
('学习交流区', '为大家提供一个学习分享的平台'),
('校园活动', '展示校园内外活动信息的平台'),
('心情随笔', '分享个人心情和生活点滴'),
('就业指导', '为同学们提供就业信息和指导'),
('社团活动', '分享各类社团活动和消息'),
('生活攻略', '分享校园生活中的各类小贴士'),
('体育竞技', '体育爱好者的交流平台');

INSERT INTO Apply(name, description) VALUES
('文化艺术', '文化与艺术爱好者的讨论区'),
('游戏区', '提供游戏相关的讨论和分享');

INSERT INTO user_apply(user_id, apply_id) VALUES
(1, 1), (3,2);

INSERT INTO take (user_id, course_id) VALUES
(1, 1), (1, 2), (1, 3), (2, 4), (2, 5), (3, 6), (3, 7),
(4, 8), (4, 9), (5, 10), (6, 11), (6, 12), (7, 13), (8, 14),
(8, 15), (9, 16), (9, 17), (10, 18), (11, 19), (12, 20),
(13, 21), (14, 22), (15, 23), (16, 24), (17, 25);


INSERT INTO release_post (post_id, user_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7),
(8, 8), (9, 9), (10, 10), (11, 11), (12, 12), (13, 13), (14, 14),
(15, 15), (16, 16), (17, 17), (18, 18), (19, 19), (20, 20),
(21, 1), (22, 2), (23, 3), (24, 4), (25, 5), (26, 6), (27, 7),
(28, 8), (29, 9), (30, 10), (31, 11), (32, 12), (33, 13), (34, 14),
(35, 15), (36, 16), (37, 17), (38, 18), (39, 19), (40, 20);


INSERT INTO release_comment (comment_id, user_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7),
(8, 8), (9, 9), (10, 10), (11, 11), (12, 12), (13, 13), (14, 14),
(15, 15), (16, 16), (17, 17), (18, 18), (19, 19), (20, 20),
(21, 1), (22, 2), (23, 3), (24, 4), (25, 5), (26, 6), (27, 7),
(28, 8), (29, 9), (30, 10), (31, 11), (32, 12), (33, 13), (34, 14),
(35, 15), (36, 16), (37, 17), (38, 18), (39, 19), (40, 20);


INSERT INTO release_report (report_id, user_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7),
(8, 8), (9, 9), (10, 10);


INSERT INTO com_post (comment_id, post_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7),
(8, 8), (9, 9), (10, 10), (11, 11), (12, 12), (13, 13), (14, 14),
(15, 15), (16, 16), (17, 17), (18, 18), (19, 19), (20, 20),
(21, 1), (22, 2), (23, 3), (24, 4), (25, 5), (26, 6), (27, 7),
(28, 8), (29, 9), (30, 10), (31, 11), (32, 12), (33, 13), (34, 14),
(35, 15), (36, 16), (37, 17), (38, 18), (39, 19), (40, 20);


INSERT INTO parent (parent_comment_id, comment_id) VALUES
(1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 8),
(8, 9), (9, 10), (10, 11), (11, 12), (12, 13), (13, 14), (14, 15),
(15, 16), (16, 17), (17, 18), (18, 19), (19, 20), (20, 21);


INSERT INTO report_post (report_id, post_id) VALUES
(1, 5), (2, 3), (3, 7), (4, 8), (5, 6);


INSERT INTO report_comment (report_id, comment_id) VALUES
(6, 30), (7, 12), (8, 16), (9, 13), (10, 19);


INSERT INTO post_forum (post_id, forum_id)
VALUES
(1, 1), (2, 1), (3, 2), (4, 2), (5, 3),
(6, 3), (7, 4), (8, 4), (9, 5), (10, 5),
(11, 6), (12, 6), (13, 7), (14, 7), (15, 8),
(16, 8), (17, 9), (18, 9), (19, 10), (20, 10),
(21, 1), (22, 1), (23, 2), (24, 2), (25, 3),
(26, 3), (27, 4), (28, 4), (29, 5), (30, 5);

INSERT INTO manage_forum (user_id, forum_id) VALUES
(1, 1), (1, 2), (1, 3), (2, 4),
(3, 5), (3, 6), (3, 7), (6, 8);
