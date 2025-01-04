from functools import wraps

from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for, jsonify
)
from werkzeug.exceptions import abort

from db import get_db

bp = Blueprint('blog', __name__)  # 无urlprefix，因此用于根目录


def login_checked(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not g.user:
            return jsonify({
                'success': False,
                'message': '用户未登录'
            })
        return f(*args, **kwargs)
    return decorated_function


@bp.route('/', methods=['GET'])
def index():
    return redirect(url_for('blog.page', page_id=1))


@bp.route('/p<int:page_id>', methods=['GET'])
def page(page_id):
    posts_per_page = 20
    offset = (page_id - 1) * posts_per_page
    db = get_db()
    posts_query = """
            SELECT p.post_id, p.title, p.body, rp.updated
            FROM release_post rp
            JOIN post p ON rp.post_id = p.post_id
            ORDER BY rp.updated DESC
            LIMIT ? OFFSET ?
        """
    posts = db.execute(posts_query, [posts_per_page, offset]).fetchall()
    # return render_template('blog/index.html', posts=posts, page_id=page_id)
    posts_list = [dict(post) for post in posts]
    return jsonify(posts_list)


@bp.route('/forum<int:forum_id>', methods=['GET'])
def forum(forum_id):
    return redirect(url_for('blog.forumPage', page_id=1, forum_id=forum_id))


@bp.route('/forum<int:forum_id>/p<int:page_id>', methods=['GET'])
def forumPage(forum_id, page_id):
    posts_per_page = 20
    offset = (page_id - 1) * posts_per_page
    db = get_db()
    posts_query = """
            SELECT p.post_id, p.title, p.body, rp.updated
            FROM post_forum pf
            JOIN post p ON pf.post_id = p.post_id
            JOIN release_post rp ON pf.post_id = rp.post_id
            WHERE pf.forum_id = ?
            ORDER BY rp.updated DESC
            LIMIT ? OFFSET ?
        """
    posts = db.execute(posts_query, [forum_id, posts_per_page, offset]).fetchall()
    # return render_template('blog/index.html', posts=posts, page_id=page_id)
    posts_list = [dict(post) for post in posts]
    return jsonify(posts_list)


@bp.route('/apply_forum', methods=['POST'])
@login_checked
def apply_forum():
    db = get_db()
    count = db.execute('''
            SELECT COUNT(*) FROM Forum
        ''').fetchone()[0]
    if count >= 10:
        return jsonify({
            'success': False,
            'message': '申请失败，论坛数量超过上限'
        })
    forum_name = request.form['forum_name']
    description = request.form['description']
    user_id = g.user['user_id']
    if not forum_name or not description:
        return jsonify({
            'success': False,
            'message': '论坛名称或者描述为空'
        })
    db.execute('''
            INSERT INTO Apply (forum_name, description) VALUE (?,?)
        ''', (forum_name, description,))
    db.commit()
    apply_id = db.execute('''SELECT last_insert_rowid()''').fetchone()[0]
    db.execute('''INSERT INTO user_apply (user_id, apply_id) 
                      VALUES (?, ?)''', (user_id, apply_id))
    db.commit()
    return jsonify({
        'success': True,
        'message': '创建论坛成功'
    }), 200


@bp.route('/forum<int:forum_id>/release_post', methods=['POST'])
@login_checked
def release_post(forum_id):
    db = get_db()
    title = request.form['title']
    body = request.form['body']
    user_id = g.user['user_id']
    if not title or not body:
        return jsonify({
            'success': False,
            'message': '标题或内容为空'
        })
    if not forum_id:
        return jsonify({
            'success': False,
            'message': '找不到论坛'
        }), 404
    db.execute('''
            INSERT INTO Post (title, body) VALUE (?,?)
        ''', (title, body,))
    db.commit()
    post_id = db.execute('''SELECT last_insert_rowid()''').fetchone()[0]
    db.execute('''INSERT INTO post_forum (post_id, forum_id) 
                      VALUES (?, ?)''', (post_id, forum_id))
    db.commit()
    db.execute('''INSERT INTO release_post (post_id, user_id) 
                      VALUES (?, ?)''', (post_id, user_id))
    db.commit()
    return jsonify({
        'success': True,
        'message': '创建帖子成功'
    }), 200


@bp.route('/post<int:post_id>', methods=['GET'])
def post(post_id):
    db = get_db()
    cur_post = db.execute('''
        SELECT *
        FROM Post p
        JOIN release_post rp ON rp.post_id = p.post_id
        JOIN User u ON u.user_id = rp.user_id
        JOIN post_forum pf ON p.post_id = pf.post_id
        JOIN Forum f ON f.forum_id = pf.forum_id
        WHERE p.post_id = ?
    ''', (post_id, )).fetchall()
    comments = db.execute('''
        SELECT *
        FROM Comment c
        JOIN release_comment rc ON rc.comment_id = c.comment_id
        JOIN User u ON u.user_id = rc.user_id
        JOIN com_post cp ON cp.comment_id = c.comment_id
        JOIN Post p ON p.post_id = cp.post_id
        WHERE p.post_id = ? 
    ''', (post_id, )).fetchall()
    post_list = dict(cur_post)
    comment_list = [dict(comment) for comment in comments]
    return jsonify({
        'post': post_list,
        'comment': comment_list
    })


@bp.route('/post<int:post_id>/release_comment', methods=['POST'])
@login_checked
def release_comment(post_id):
    db = get_db()
    user_id = g.user['user_id']
    body = request.form['body']
    db.execute('''
        INSERT INTO Comment (body) VALUE ?
    ''', (body, ))
    db.commit()
    comment_id = db.execute('''SELECT last_insert_rowid()''').fetchone()[0]
    db.execute('''
        INSERT INTO release_comment (user_id, comment_id) VALUE (?, ?)
    ''', (user_id, comment_id))
    db.commit()
    db.execute('''
        INSERT INTO com_post (comment_id, post_id) VALUE (?,?)
    ''', (comment_id, post_id))
    db.commit()
    return jsonify({
        'success': True,
        'message': '发布评论成功'
    })


@bp.route('/get_forums', methods=['GET'])
def get_forums():
    db = get_db()
    forums = db.execute('''
        SELECT * FROM Forum 
    ''').fetchall()
    forum_list = [dict(forum) for forum in forums]
    return jsonify(forum_list)


@bp.route('/get_courses', methods=['GET'])
def get_courses():
    db = get_db()
    courses = db.execute('''
        SELECT * FROM Courses
    ''').fetchall()
    course_list = [dict(course) for course in courses]
    return jsonify(course_list)


@bp.route('/comment<int:comment_id>/add_like', methods=['POST'])
@login_checked
def like_comment(comment_id):
    db = get_db()
    user_id = g.user['user_id']
    try:
        db.execute('''
            INSERT INTO like_comment (user_id, comment_id) VALUE (?,?)
        ''', (user_id, comment_id))
        db.commit()
    except db.IntegrityError:
        return jsonify({
            'success': False,
            'message': '点赞失败，已经存在该记录'
        })
    return jsonify({
        'success': True,
        'message': '点赞成功'
    })


@bp.route('/comment<int:comment_id>/cancel_like', methods=['POST'])
@login_checked
def cancel_like(comment_id):
    db = get_db()
    user_id = g.user['user_id']
    cur_like_comment = db.execute('''
        SELECT 1 FROM like_comment WHERE user_id = ? AND comment_id = ?
    ''', (user_id, comment_id)).fetchone()
    if not cur_like_comment:
        return jsonify({
            'success': False,
            'message': '取消点赞失败，未存在该记录'
        }), 404
    db.execute('''
            DELETE FROM like_comment WHERE user_id = ? AND comment_id = ?
        ''', (user_id, comment_id))
    db.commit()
    return jsonify({
        'success': True,
        'message': '取消点赞成功'
    })


@bp.route('/comment<int:comment_id>/click_like', methods=['POST'])
@login_checked
def click_like(comment_id):
    db = get_db()
    user_id = g.user['user_id']
    cur_like_comment = db.execute('''
            SELECT 1 FROM like_comment WHERE user_id = ? AND comment_id = ?
        ''', (user_id, comment_id)).fetchone()
    if not cur_like_comment:
        db.execute('''
                    INSERT INTO like_comment (user_id, comment_id) VALUE (?,?)
                ''', (user_id, comment_id))
        db.commit()
        return jsonify({
            'success': True,
            'message': '点赞成功'
        })
    else:
        db.execute('''
                DELETE FROM like_comment WHERE user_id = ? AND comment_id = ?
            ''', (user_id, comment_id))
        db.commit()
        return jsonify({
            'success': True,
            'message': '取消点赞成功'
        })


@bp.route('/submit_report_post<int:post_id>', methods=['GET'])
@login_checked
def submit_report_post(post_id):
    reason = request.form['reason']
    user_id = g.user['user_id']
    db = get_db()
    db.execute('''
        INSERT INTO Report (reason) VALUE (?)
    ''', (reason, ))
    db.commit()
    report_id = db.execute('''SELECT last_insert_rowid()''').fetchone()[0]
    db.execute('''
        INSERT INTO report_post (report_id, post_id) VALUE (?, ?)
    ''', (report_id, post_id))
    db.commit()
    db.execute('''
        INSERT INTO release_report (user_id, report_id) VALUE (?, ?)
    ''', (user_id, report_id))
    db.commit()
    return jsonify({
        'success': True,
        'message': '提交帖子举报成功'
    })


@bp.route('/submit_report_comment<int:comment_id>', methods=['GET'])
@login_checked
def submit_report_comment(comment_id):
    reason = request.form['reason']
    user_id = g.user['user_id']
    db = get_db()
    db.execute('''
        INSERT INTO Report (reason) VALUE (?)
    ''', (reason, ))
    db.commit()
    report_id = db.execute('''SELECT last_insert_rowid()''').fetchone()[0]
    db.execute('''
        INSERT INTO report_comment (report_id, comment_id) VALUE (?, ?)
    ''', (report_id, comment_id))
    db.commit()
    db.execute('''
        INSERT INTO release_report (user_id, report_id) VALUE (?, ?)
    ''', (user_id, report_id))
    db.commit()
    return jsonify({
        'success': True,
        'message': '提交评论举报成功'
    })
