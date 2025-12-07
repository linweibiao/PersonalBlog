"""
应用初始化模块
==================
创建Flask应用实例，初始化扩展和注册蓝图
"""

from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_sqlalchemy import SQLAlchemy
from app.config import Config

# 初始化扩展
db = SQLAlchemy()  # SQLAlchemy数据库实例
jwt = JWTManager()  # JWT认证管理器


def create_app(config_class=Config):
    """
    创建并配置Flask应用
    
    Args:
        config_class: 配置类，默认使用Config
    
    Returns:
        Flask: 配置完成的Flask应用实例
    """
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # 初始化扩展
    db.init_app(app)
    jwt.init_app(app)
    
    # 配置CORS，确保OPTIONS请求能正确处理
    # 允许所有来源，支持凭证，允许所有方法和头
    # 这可以确保浏览器预检请求不会被重定向
    CORS(app, 
         origins="*", 
         supports_credentials=True, 
         allow_headers="*", 
         methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    
    # 注册蓝图
    from app.routes.auth import auth_bp        # 认证蓝图
    from app.routes.articles import articles_bp  # 文章蓝图
    from app.routes.comments import comments_bp  # 评论蓝图
    from app.routes.admin import admin_bp        # 管理员蓝图
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')      # 注册认证路由
    app.register_blueprint(articles_bp, url_prefix='/api/articles')  # 注册文章路由
    app.register_blueprint(comments_bp, url_prefix='/api/comments')  # 注册评论路由
    app.register_blueprint(admin_bp, url_prefix='/api/admin')        # 注册管理员路由
    
    # 创建数据库表
    with app.app_context():
        db.create_all()
    
    return app