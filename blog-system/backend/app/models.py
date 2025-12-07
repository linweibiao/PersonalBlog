"""
数据模型模块
==================
定义应用的数据模型，包括用户、文章和评论模型
"""

from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, ForeignKey, Enum, DateTime
from sqlalchemy.sql import func
import enum
from app import db


# 枚举类型定义
class UserRole(enum.Enum):
    """用户角色枚举"""
    user = 'user'  # 普通用户
    admin = 'admin'  # 管理员


class ArticleStatus(enum.Enum):
    """文章状态枚举"""
    draft = 'draft'  # 草稿
    published = 'published'  # 已发布


# 用户模型
class User(db.Model):
    """
    用户数据模型
    
    存储系统用户的基本信息
    """
    
    __tablename__ = 'users'  # 数据库表名
    
    id = Column(Integer, primary_key=True, autoincrement=True)  # 用户ID，主键
    username = Column(String(50), unique=True, nullable=False)  # 用户名，唯一且必填
    email = Column(String(100), unique=True, nullable=False)  # 邮箱，唯一且必填
    password_hash = Column(String(255), nullable=False)  # 密码哈希，必填
    role = Column(Enum(UserRole), default=UserRole.user)  # 用户角色，默认普通用户
    created_at = Column(DateTime(timezone=True), server_default=func.now())  # 创建时间，自动生成


# 文章模型
class Article(db.Model):
    """
    文章数据模型
    
    存储博客文章的基本信息
    """
    
    __tablename__ = 'articles'  # 数据库表名
    
    id = Column(Integer, primary_key=True, autoincrement=True)  # 文章ID，主键
    title = Column(String(200), nullable=False)  # 文章标题，必填
    content = Column(Text, nullable=False)  # 文章内容，必填
    author_id = Column(Integer, ForeignKey('users.id'), nullable=False)  # 作者ID，外键关联用户表
    status = Column(Enum(ArticleStatus), default=ArticleStatus.draft)  # 文章状态，默认草稿
    category = Column(String(50))  # 文章分类
    tags = Column(Text)  # 文章标签，使用Text存储JSON格式的标签
    created_at = Column(DateTime(timezone=True), server_default=func.now())  # 创建时间，自动生成
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())  # 更新时间，自动更新


# 评论模型
class Comment(db.Model):
    """
    评论数据模型
    
    存储文章评论的基本信息
    """
    
    __tablename__ = 'comments'  # 数据库表名
    
    id = Column(Integer, primary_key=True, autoincrement=True)  # 评论ID，主键
    article_id = Column(Integer, ForeignKey('articles.id'), nullable=False)  # 文章ID，外键关联文章表
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)  # 用户ID，外键关联用户表
    content = Column(Text, nullable=False)  # 评论内容，必填
    created_at = Column(DateTime(timezone=True), server_default=func.now())  # 创建时间，自动生成