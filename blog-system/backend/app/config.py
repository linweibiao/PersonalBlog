"""
应用配置模块
==================
定义应用的配置项，包括数据库、JWT认证等配置
"""

import os
from datetime import timedelta


class Config:
    """
    应用配置类
    
    定义了应用的各项配置，包括数据库配置、JWT认证配置等
    """
    
    # 应用基础目录配置
    BASE_DIR = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))  # 获取应用根目录
    
    # 实例目录配置
    INSTANCE_DIR = os.path.join(BASE_DIR, 'instance')  # 实例目录路径
    if not os.path.exists(INSTANCE_DIR):
        os.makedirs(INSTANCE_DIR)  # 确保实例目录存在
    
    # 数据库配置
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or f'sqlite:///{os.path.join(INSTANCE_DIR, "blog_system.db")}'  # 数据库连接URL
    SQLALCHEMY_TRACK_MODIFICATIONS = False  # 关闭SQLAlchemy的修改追踪
    
    # JWT认证配置
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'your-secret-key-here'  # JWT密钥
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=1)  # JWT令牌过期时间
    
    # Flask应用配置
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key'  # Flask应用密钥