from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from app.models import Comment, Article, User
from app import db

comments_bp = Blueprint('comments', __name__)

@comments_bp.route('/', methods=['GET'])
def get_comments():
    """获取评论列表（可按文章过滤）"""
    article_id = request.args.get('article_id', type=int)
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    # 构建查询
    query = Comment.query
    if article_id:
        query = query.filter_by(article_id=article_id)
    
    # 分页查询
    pagination = query.order_by(Comment.created_at.desc()).paginate(page=page, per_page=per_page, error_out=False)
    
    # 构建响应
    comments = []
    for comment in pagination.items:
        user = User.query.get(comment.user_id)
        comments.append({
            'id': comment.id,
            'article_id': comment.article_id,
            'user_id': comment.user_id,
            'username': user.username,
            'content': comment.content,
            'created_at': comment.created_at.isoformat()
        })
    
    return jsonify({
        'comments': comments,
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': pagination.page
    })

@comments_bp.route('/', methods=['POST'])
@jwt_required()
def create_comment():
    """创建评论"""
    current_user_id = get_jwt_identity()
    data = request.get_json()
    
    # 验证请求数据
    if not data or 'content' not in data or not data['content']:
        return jsonify({'message': '评论内容不能为空'}), 400
    
    if 'article_id' not in data or not data['article_id']:
        return jsonify({'message': '文章ID不能为空'}), 400
    
    # 检查文章是否存在
    article = Article.query.get(data['article_id'])
    if not article:
        return jsonify({'message': '文章不存在'}), 404
    
    # 创建评论
    comment = Comment(
        article_id=data['article_id'],
        user_id=current_user_id,
        content=data['content']
    )
    
    db.session.add(comment)
    db.session.commit()
    
    # 获取评论作者信息
    user = User.query.get(current_user_id)
    
    return jsonify({
        'id': comment.id,
        'article_id': comment.article_id,
        'user_id': comment.user_id,
        'username': user.username,
        'content': comment.content,
        'created_at': comment.created_at.isoformat()
    }), 201

@comments_bp.route('/<int:comment_id>', methods=['DELETE'])
@jwt_required()
def delete_comment(comment_id):
    """删除评论"""
    current_user_id = get_jwt_identity()
    claims = get_jwt()
    current_role = claims.get('role', 'user')
    
    comment = Comment.query.get_or_404(comment_id)
    
    # 检查权限（评论者、文章作者或管理员可以删除）
    is_comment_owner = comment.user_id == current_user_id
    is_admin = current_role == 'admin'
    
    # 获取文章作者信息
    article = Article.query.get(comment.article_id)
    is_article_owner = article.author_id == current_user_id if article else False
    
    if not (is_comment_owner or is_article_owner or is_admin):
        return jsonify({'message': '无权删除此评论'}), 403
    
    db.session.delete(comment)
    db.session.commit()
    
    return jsonify({'message': '评论删除成功'})