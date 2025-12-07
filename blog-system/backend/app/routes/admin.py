from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt
from app.models import User, Article, Comment, ArticleStatus, UserRole
from app import db
from app.utils.auth import hash_password
import json
import traceback

admin_bp = Blueprint('admin', __name__)

def admin_required():
    """管理员权限装饰器"""
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify({'message': '需要管理员权限'}), 403
    return None

@admin_bp.route('/users', methods=['GET'])
@jwt_required()
def get_all_users():
    """获取所有用户列表"""
    print("接收到获取用户列表的请求")
    
    # 检查管理员权限
    error = admin_required()
    if error:
        return error
    
    try:
        
        # 安全地获取请求参数，确保类型正确
        try:
            page = request.args.get('page', 1)
            per_page = request.args.get('per_page', 10)
            search = request.args.get('search', '', type=str)
            
            # 验证并转换页码和每页数量
            try:
                page = int(page)
                per_page = int(per_page)
                # 验证参数范围
                page = max(1, page)  # 确保页码至少为1
                per_page = min(100, max(1, per_page))  # 限制每页数量在1-100之间
            except ValueError:
                print("页码或每页数量不是有效整数，使用默认值")
                page = 1
                per_page = 10
                
            print(f"解析参数成功: page={page}, per_page={per_page}, search={search}")
        except Exception as e:
            print(f"参数处理异常: {type(e).__name__}: {str(e)}")
            return jsonify({
                'message': '请求参数格式错误',
                'error_type': type(e).__name__,
                'error_details': str(e)
            }), 400
        
        # 构建查询
        query = User.query
        
        # 添加搜索条件
        if search:
            print(f"应用搜索条件: {search}")
            query = query.filter(User.username.ilike(f'%{search}%') | User.email.ilike(f'%{search}%'))
        
        try:
            # 执行分页查询
            print("执行用户数据分页查询")
            pagination = query.paginate(page=page, per_page=per_page, error_out=False)
            print(f"查询成功，找到{pagination.total}个用户")
            
            # 构建响应数据
            user_list = []
            for user in pagination.items:
                try:
                    user_dict = {
                        'id': int(user.id),  # 确保ID是整数
                        'username': str(user.username) if user.username else '',  # 确保是字符串并处理空值
                        'email': str(user.email) if user.email else '',  # 确保是字符串并处理空值
                        'role': str(user.role.value) if hasattr(user.role, 'value') else str(user.role),  # 安全获取角色值
                        'created_at': user.created_at.isoformat() if user.created_at else None  # 处理可能的空值
                    }
                    user_list.append(user_dict)
                except Exception as e:
                    print(f"处理用户数据时出错: {type(e).__name__}: {str(e)}")
                    # 跳过有问题的用户数据，继续处理其他用户
                    continue
            
            # 构造最终响应
            response_data = {
                'users': user_list,
                'total': pagination.total,
                'page': page,
                'per_page': per_page,
                'pages': pagination.pages
            }
            
            print(f"响应数据构造完成，包含{len(user_list)}个用户")
            return jsonify(response_data), 200
        except Exception as e:
            print(f"数据库查询或处理异常: {type(e).__name__}: {str(e)}")
            traceback.print_exc()
            return jsonify({
                'message': '数据处理错误',
                'error_type': type(e).__name__,
                'error_details': str(e)
            }), 500
    
    except Exception as e:
        print(f"发生未捕获异常: {type(e).__name__}: {str(e)}")
        traceback.print_exc()
        return jsonify({
            'message': '服务器内部错误',
            'error_type': type(e).__name__,
            'error_details': str(e)
        }), 500

@admin_bp.route('/users/<int:user_id>', methods=['GET'])
@jwt_required()
def get_user(user_id):
    """获取单个用户信息"""
    print("接收到获取用户信息的请求")
    
    # 检查管理员权限
    error = admin_required()
    if error:
        return error
    
    user = User.query.get_or_404(user_id)
    
    user_data = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'role': user.role.value if hasattr(user.role, 'value') else user.role,
        'created_at': user.created_at.isoformat() if user.created_at else None
    }
    
    return jsonify(user_data), 200

@admin_bp.route('/users/<int:user_id>', methods=['PUT'])
@jwt_required()
def update_user(user_id):
    """更新用户信息"""
    print("接收到更新用户信息的请求")
    
    # 检查管理员权限
    error = admin_required()
    if error:
        return error
    
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    
    # 更新用户名
    if 'username' in data:
        user.username = data['username']
    
    # 更新邮箱
    if 'email' in data:
        user.email = data['email']
    
    # 更新角色
    if 'role' in data:
        user.role = UserRole[data['role']] if isinstance(data['role'], str) else data['role']
    
    # 更新密码
    if 'password' in data and data['password']:
        user.password_hash = hash_password(data['password'])
    
    db.session.commit()
    
    return jsonify({'message': '用户信息更新成功'})

@admin_bp.route('/users/<int:user_id>', methods=['DELETE'])
@jwt_required()
def delete_user(user_id):
    """删除用户"""
    print("接收到删除用户的请求")
    
    # 检查管理员权限
    error = admin_required()
    if error:
        return error
    
    user = User.query.get_or_404(user_id)
    
    # 删除该用户的所有评论
    Comment.query.filter_by(user_id=user_id).delete()
    
    # 删除该用户的所有文章
    Article.query.filter_by(author_id=user_id).delete()
    
    # 删除用户
    db.session.delete(user)
    db.session.commit()
    
    return jsonify({'message': '用户删除成功'})

@admin_bp.route('/articles/all', methods=['GET'])
@jwt_required()
def get_all_articles():
    """获取所有文章（包括草稿）"""
    error = admin_required()
    if error:
        return error
    
    articles = Article.query.all()
    article_list = []
    for article in articles:
        article_list.append({
            'id': article.id,
            'title': article.title,
            'author_id': article.author_id,
            'status': article.status.value,
            'category': article.category,
            'tags': json.loads(article.tags) if article.tags else [],
            'created_at': article.created_at.isoformat()
        })
    
    return jsonify({'articles': article_list})

@admin_bp.route('/statistics', methods=['GET'])
@jwt_required()
def get_statistics():
    """获取站点统计信息"""
    error = admin_required()
    if error:
        return error
    
    # 统计数据
    total_users = User.query.count()
    total_articles = Article.query.count()
    published_articles = Article.query.filter_by(status=ArticleStatus.published).count()
    draft_articles = Article.query.filter_by(status=ArticleStatus.draft).count()
    total_comments = Comment.query.count()
    
    return jsonify({
        'total_users': total_users,
        'total_articles': total_articles,
        'published_articles': published_articles,
        'draft_articles': draft_articles,
        'total_comments': total_comments
    })