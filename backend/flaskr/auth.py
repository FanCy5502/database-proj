# 认证蓝图：注册新用户、登录和注销视图
import os
import random
from pathlib import Path
import functools

from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for, jsonify
)

from werkzeug.security import check_password_hash, generate_password_hash

from db import get_db

bp = Blueprint('auth', __name__, url_prefix='/auth')


# 注册视图
# 填写初测内容的表单页面
@bp.route('/register', methods=['POST'])
def register():
    username = request.form['username']
    password = request.form['password']
    nickname = request.form['nickname']
    db = get_db()
    if not username or not password or not nickname:
        return jsonify({
            'success': False,
            'message': '注册失败，用户名或密码或昵称为空'
        })
    try:
        db.execute(
            "INSERT INTO user (username,password, nickname) VALUES (?,?,?)",
            (username, generate_password_hash(password), nickname),
        )
        db.commit()
    except db.IntegrityError:
        return jsonify({
            'success': True,
            'massage': '注册失败，该用户名已经注册过'
        })

    return jsonify({
        'success': True,
        'massage': '注册成功'
    })


# 登录视图
@bp.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    db = get_db()
    user = db.execute(
        'SELECT * FROM user WHERE username = ?', (username,)
    ).fetchone()
    if user is None:
        return jsonify({
            'success': False,
            'message': '登录失败，不存在的用户名'
        })
    elif not check_password_hash(user['password'], password):  # 匹配密码
        return jsonify({
            'success': False,
            'message': '登录失败，密码错误'
        })
    # 验证成功后，用户id存储在以新会话（session:用于存储横跨请求的值的dict）中;session数据会存储到一个向浏览器发送的cookie中。
    session.clear()
    session['user_id'] = user['id']
    return jsonify({
        'success': True,
        'message': '登录成功'
    })


@bp.route('/admin_login', methods=['POST'])
def admin_login():
    username = request.form['username']
    password = request.form['password']
    db = get_db()
    user = db.execute(
        'SELECT * FROM user WHERE username = ? AND category = "admin"', (username,)
    ).fetchone()
    if user is None:
        return jsonify({
            'success': False,
            'message': '登录失败，不存在的用户名'
        })
    elif not check_password_hash(user['password'], password):  # 匹配密码
        return jsonify({
            'success': False,
            'message': '登录失败，密码错误'
        })
    # 验证成功后，用户id存储在以新会话（session:用于存储横跨请求的值的dict）中;session数据会存储到一个向浏览器发送的cookie中。
    session.clear()
    session['user_id'] = user['id']
    return jsonify({
        'success': True,
        'message': '登录成功'
    })


# 加载已登录的用户
# 在视图函数（不论其对应的url）之前运行的函数，用于检查用户id是否已经存储在session中，并从数据库中获取用户数据，存储在g.user中。
@bp.before_app_request
def load_logged_in_user():
    user_id = session.get('user_id')
    if user_id is None:
        g.user = None
    else:
        g.user = get_db().execute(
            'SELECT * FROM user WHERE id = ?', (user_id,)
        ).fetchone()
    # 如没有user_id或id不存在，则g.user为None


# 注销
# 将某已登录的用户id从session中移除
@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))


@bp.route('/profile', methods=['GET'])
def profile():
    if not g.user:
        return jsonify({
            'success': False,
            'message': '请先登录'
        })
    db = get_db()
    user_id = g.user['user_id']
    user_profile = db.execute('''
        SELECT * FROM User u WHERE u.user_id = ?
    ''', (user_id, )).fetchone()
    user_dict = dict(user_profile)
    return jsonify(user_dict)


@bp.route('/reset_password', methods=['POST'])
def reset_password():
    if not g.user:
        return jsonify({
            'success': False,
            'message': '设置密码失败，请先登录'
        })
    db = get_db()
    user_id = g.user['user_id']
    old_password = request.form['old_password']
    new_password = request.form['new_password']
    if not old_password or not new_password:
        return jsonify({
            'success': False,
            'message': '设置密码失败，空的密码'
        })
    if not check_password_hash(g.user['password'], old_password):
        return jsonify({
            'success': False,
            'message': '设置密码失败，错误的旧密码'
        }), 400
    hashed_password = generate_password_hash(new_password)
    db.execute('''
        UPDATE User SET password = ? WHERE user_id = ?
    ''', (hashed_password, user_id))
    return jsonify({
        'success': True,
        'message': '重设密码成功'
    }), 200


@bp.route('/set_nickname', methods=['POST'])
def set_nickname():
    if not g.user:
        return jsonify({
            'success': False,
            'message': '设置密码失败，请先登录'
        })
    db = get_db()
    user_id = g.user['user_id']
    new_nickname = request.form['nickname']
    db.execute('''
        UPDATE user SET nickname = ? WHERE user_id = ?
    ''', (new_nickname, user_id))
    return jsonify({
        'success': True,
        'message': '修改昵称成功'
    })


@bp.route('/set_grade', methods=['POST'])
def set_grade():
    if not g.user:
        return jsonify({
            'success': False,
            'message': '修改年级失败，请先登录'
        })
    db = get_db()
    user_id = g.user['user_id']
    grade = request.form['grade']
    db.execute('''
        UPDATE user SET grade = ? WHERE user_id = ?
    ''', (grade, user_id))
    return jsonify({
        'success': True,
        'message': '修改年级成功'
    })


@bp.route('/set_major', methods=['POST'])
def set_major():
    if not g.user:
        return jsonify({
            'success': False,
            'message': '修改专业失败，请先登录'
        })
    db = get_db()
    user_id = g.user['user_id']
    major = request.form['major']
    db.execute('''
        UPDATE user SET major = ? WHERE user_id = ?
    ''', (major, user_id))
    return jsonify({
        'success': True,
        'message': '修改专业成功'
    })


CAPTCHA_FOLDER = Path("captcha")


@bp.route('/get_captcha', methods=['GET'])
def get_captcha():
    captcha_files = [f for f in os.listdir(CAPTCHA_FOLDER) if f.endswith('.png')]
    if not captcha_files:
        return jsonify({'success': False, 'message': 'No captcha files available'}), 404

    selected_file = random.choice(captcha_files)
    captcha_url = url_for('static', filename=f'captcha/{selected_file}')
    return jsonify({
        'link': captcha_url,
        'captcha': selected_file
    })
