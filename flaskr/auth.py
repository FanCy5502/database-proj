# 认证蓝图：注册新用户、登录和注销视图

import functools

from flask import(
    Blueprint, flash, g, redirect, render_template, request, session, url_for
)

from werkzeug.security import check_password_hash, generate_password_hash

from flaskr.db import get_db

bp = Blueprint('auth',__name__,url_prefix='/auth')

# 注册视图
# 填写初测内容的表单页面
@bp.route('/register',methods=('GET','POST'))
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        error = None

        if not username:
            error = 'Username is required.'
        elif not password:
            error = 'Password is required.'

        if error is None:
            try:
                db.execute(
                    "INSERT INTO user (username,password) VALUES (?,?)",
                    (username,generate_password_hash(password)),
                )
                db.commit() # 查询修改了数据，因此需要保存修改
            except db.IntegrityError:
                error = f"User {username} is already registered."
            else:
                return redirect(url_for("auth.login")) # 正确完成注册
            
        flash(error)

    return render_template('auth/register.html')

# 登录视图
@bp.route('/login',methods=('GET','POST'))
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        db = get_db()
        error = None
        user = db.execute(
            'SELECT * FROM user WHERE username = ?',(username,)
        ).fetchone() # 根据查询返回一个记录行

        if user is None:
            error = 'Incorrect username.'
        elif not check_password_hash(user['password'],password): # 匹配密码
            error = 'Incorrect password.'
        
        # 验证成功后，用户id存储在以新会话（session:用于存储横跨请求的值的dict）中;session数据会存储到一个向浏览器发送的cookie中。
        if error is None:
            session.clear() 
            session['user_id'] = user['id']
            return redirect(url_for('index'))
        flash(error)

    return render_template('auth/login.html')

# 加载已登录的用户
# 在视图函数（不论其对应的url）之前运行的函数，用于检查用户id是否已经存储在session中，并从数据库中获取用户数据，存储在g.user中。
@bp.before_app_request
def load_logged_in_user():
    user_id = session.get('user_id')
    if user_id is None:
        g.user = None
    else:
        g.user = get_db().execute(
            'SELECT * FROM user WHERE id = ?',(user_id,)
        ).fetchone()
    # 如没有user_id或id不存在，则g.user为None

# 注销
# 将某已登录的用户id从session中移除
@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

# 在每个视图中都可以完成的
# 登陆后，可进行创建、编辑和删除博客和帖子
def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None: # 当前没有处于登录状态的用户，则要求登录
            return redirect(url_for('auth.login'))
        return view(**kwargs) # 调用原始视图函数view，并返回视图的结果
    return wrapped_view # 返回经过包装的视图函数

