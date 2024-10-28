from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from werkzeug.exceptions import abort

from flaskr.auth import login_required
from flaskr.db import get_db

bp = Blueprint('blog', __name__)  # 无urlprefix，因此用于根目录


@bp.route('/')
def index():
    db = get_db()
    posts = db.execute(
        'SELECT p.id, title, body,created, author_id, username, forum_name, p.forum_id'
        ' FROM post p '
        'JOIN user u ON p.author_id = u.id '
        'JOIN forums f ON p.forum_id = f.forum_id'
        ' ORDER BY created DESC, p.id DESC'
    ).fetchall()
    comments = db.execute(
        ' SELECT * '
        ' FROM comment c '
        ' JOIN user u ON c.user_id = u.id '
        ' JOIN post p ON c.post_id = p.id '
        ' ORDER BY created ASC, c.comment_id ASC'
    )
    # TODO for frontend: 请完善前端代码
    return render_template('blog/index.html', posts=posts, comments=comments)


# 创建视图
@bp.route('/create', methods=('GET', 'POST'))
@login_required
def create():
    db = get_db()
    forums = db.execute('SELECT forum_id, forum_name FROM forums').fetchall()
    if request.method == 'POST':
        title = request.form['title']
        body = request.form['body']
        forum_id = request.form.get('forum_id')  # 获取选择的论坛 ID

        if not title:
            flash('Title is required.')
        else:
            db.execute(
                'INSERT INTO post (title,body,author_id,forum_id) VALUES (?,?,?,?)',
                (title, body, g.user['id'], forum_id)
            )
            db.commit()
            return redirect(url_for('blog.index'))
    # TODO for frontend: 请完善前端代码
    return render_template('blog/create.html', forums=forums)


def get_post(id, check_author=True):
    post = get_db().execute(
        'SELECT p.id, title, body, created, author_id, username'
        ' FROM post p JOIN user u ON p.author_id = u.id'
        ' WHERE p.id = ?',
        (id,)
    ).fetchone()  # id

    if post is None:
        abort(404, f"Post id {id} doesn't exist.")

    if check_author and post['author_id'] != g.user['id']:
        abort(403)

    return post


@bp.route('/<int:id>/update', methods=('GET', 'POST'))
@login_required
def update(id):
    post = get_post(id)

    if request.method == 'POST':
        title = request.form['title']
        body = request.form['body']
        error = None

        if not title:
            error = 'Title is required.'

        if error is not None:
            flash(error)
        else:
            db = get_db()
            db.execute(
                'UPDATE post SET title = ?, body = ?'
                ' WHERE id = ?',
                (title, body, id)
            )
            db.commit()
            return redirect(url_for('blog.index'))
    # TODO for frontend: 请完善前端代码
    return render_template('blog/update.html', post=post)


@bp.route('/<int:id>/delete', methods=('POST',))
@login_required
def delete(id):
    get_post(id)
    db = get_db()
    db.execute('DELETE FROM post WHERE id = ?', (id,))
    db.commit()
    # TODO for frontend: 请完善前端代码
    return redirect(url_for('blog.index'))

@bp.route('/p/<int:post_id>', methods=('GET', 'POST'))
def post(post_id):
    db = get_db()
    post_spe = db.execute(
        ' SELECT *'
        ' FROM post p'
        ' JOIN forums f ON p.forum_id = f.forum_id'
        ' JOIN user u ON p.author_id = u.id'
        ' WHERE p.id = ?',
        (post_id,)
    ).fetchone()
    comments = db.execute(
        ' SELECT * '
        ' FROM post p '
        ' JOIN comment c ON p.id = c.comment_id '
        ' WHERE c.post_id = ? '
        ' ORDER BY created DESC, c.comment_id DESC ',
        (post_id,)
    ).fetchall()
    # TODO for frontend: 请完善前端代码
    return render_template('blog/post.html', post=post_spe, comments=comments)


@bp.route('/f/<int:forum_id>', methods=('GET', 'POST'))
def forum(forum_id):
    db = get_db()
    posts = db.execute(
        ' SELECT p.id, title, body,created, author_id, username, forum_name'
        ' FROM post p '
        ' JOIN user u ON p.author_id = u.id '
        ' JOIN forums f ON p.forum_id = f.forum_id'
        ' WHERE f.forum_id = ?'
        ' ORDER BY created DESC, p.id DESC',
        (forum_id,)
    ).fetchall()
    forum_name_row = db.execute(
        'SELECT forum_name FROM forums WHERE forum_id = ?',
        (forum_id,)
    ).fetchone()
    comments = db.execute(
        ' SELECT * '
        ' FROM comment c '
        ' JOIN user u ON c.user_id = u.id '
        ' JOIN post p ON c.post_id = p.id '
        ' WHERE p.forum_id = ?'
        ' ORDER BY created ASC, c.comment_id ASC',
        (forum_id,)
    )
    forum_name = forum_name_row['forum_name'] if forum_name_row else "forum not found"
    # TODO for frontend: 请完善前端代码
    return render_template('blog/forum.html', posts=posts, forum_name=forum_name, comments=comments)