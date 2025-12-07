from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from app.models import Article, ArticleStatus, User
from app import db
import json

articles_bp = Blueprint('articles', __name__)

@articles_bp.route('/', methods=['GET'], strict_slashes=False)
def get_articles():
    """获取文章列表"""
    # 获取查询参数
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    status = request.args.get('status', 'published')
    
    # 构建查询
    query = Article.query
    if status:
        query = query.filter_by(status=status)
    
    # 分页查询
    pagination = query.order_by(Article.created_at.desc()).paginate(page=page, per_page=per_page, error_out=False)
    
    # 构建响应
    articles = []
    for article in pagination.items:
        articles.append({
            'id': article.id,
            'title': article.title,
            'content': article.content,
            'author_id': article.author_id,
            'status': article.status.value,
            'category': article.category,
            'tags': json.loads(article.tags) if article.tags else [],
            'created_at': article.created_at.isoformat(),
            'updated_at': article.updated_at.isoformat() if article.updated_at else None
        })
    
    return jsonify({
        'articles': articles,
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': pagination.page
    })

@articles_bp.route('/<int:article_id>', methods=['GET'])
def get_article(article_id):
    """获取单篇文章"""
    article = Article.query.get_or_404(article_id)
    
    # 检查权限（只有已发布的文章或自己的草稿才能查看）
    if article.status == ArticleStatus.draft:
        try:
            current_user_id = get_jwt_identity()
            if article.author_id != current_user_id:
                return jsonify({'message': '无权访问此文章'}), 403
        except:
            return jsonify({'message': '无权访问此文章'}), 403
    
    return jsonify({
        'id': article.id,
        'title': article.title,
        'content': article.content,
        'author_id': article.author_id,
        'status': article.status.value,
        'category': article.category,
        'tags': json.loads(article.tags) if article.tags else [],
        'created_at': article.created_at.isoformat(),
        'updated_at': article.updated_at.isoformat() if article.updated_at else None
    })

@articles_bp.route('/', methods=['POST'])
@jwt_required()
def create_article():
    """创建文章"""
    current_user_id = get_jwt_identity()
    data = request.get_json()
    
    new_article = Article(
        title=data['title'],
        content=data['content'],
        author_id=current_user_id,
        status=ArticleStatus(data.get('status', 'draft')),
        category=data.get('category'),
        tags=json.dumps(data.get('tags', []))
    )
    
    db.session.add(new_article)
    db.session.commit()
    
    return jsonify({'message': '文章创建成功', 'article_id': new_article.id}), 201

@articles_bp.route('/<int:article_id>', methods=['PUT'])
@jwt_required()
def update_article(article_id):
    """更新文章"""
    current_user_id = get_jwt_identity()
    claims = get_jwt()
    current_role = claims.get('role', 'user')
    
    article = Article.query.get_or_404(article_id)
    
    # 检查权限（只有作者或管理员才能更新）
    if article.author_id != current_user_id and current_role != 'admin':
        return jsonify({'message': '无权修改此文章'}), 403
    
    data = request.get_json()
    
    # 更新字段
    if 'title' in data:
        article.title = data['title']
    if 'content' in data:
        article.content = data['content']
    if 'status' in data:
        article.status = ArticleStatus(data['status'])
    if 'category' in data:
        article.category = data['category']
    if 'tags' in data:
        article.tags = json.dumps(data['tags'])
    
    db.session.commit()
    
    return jsonify({'message': '文章更新成功'})

@articles_bp.route('/<int:article_id>', methods=['DELETE'])
@jwt_required()
def delete_article(article_id):
    """删除文章"""
    current_user_id = get_jwt_identity()
    claims = get_jwt()
    current_role = claims.get('role', 'user')
    
    article = Article.query.get_or_404(article_id)
    
    # 检查权限（只有作者或管理员才能删除）
    if article.author_id != current_user_id and current_role != 'admin':
        return jsonify({'message': '无权删除此文章'}), 403
    
    db.session.delete(article)
    db.session.commit()
    
    return jsonify({'message': '文章删除成功'})

@articles_bp.route('/<int:article_id>/comments', methods=['POST'])
@jwt_required()
def add_comment(article_id):
    """添加评论"""
    current_user_id = get_jwt_identity()
    data = request.get_json()
    
    # 验证文章是否存在
    article = Article.query.get_or_404(article_id)
    
    # 导入Comment模型避免循环导入
    from app.models import Comment
    
    new_comment = Comment(
        article_id=article_id,
        user_id=current_user_id,
        content=data['content']
    )
    
    db.session.add(new_comment)
    db.session.commit()
    
    return jsonify({'message': '评论添加成功', 'comment_id': new_comment.id}), 201