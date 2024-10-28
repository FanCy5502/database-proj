import os

from flask import Flask


# 应用工厂函数
def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
    )

    if test_config is None:
        app.config.from_pyfile('config.py', silent=True)
    else:
        app.config.from_mapping(test_config)

    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    @app.route('/hello/')
    def hello():
        return 'Hello, World!'

    from . import db
    db.init_app(app)
    with app.app_context():
        db.init_db()

    # 认证蓝图：注册新用户、登录和注销视图
    from . import auth
    app.register_blueprint(auth.bp)

    # 博客蓝图：列出帖子 创建、修改删除帖子
    from . import blog
    app.register_blueprint(blog.bp)
    app.add_url_rule('/', endpoint='index')
    # url_for('index) 或 url_for('blog.index') 生成同样的/url

    return app
