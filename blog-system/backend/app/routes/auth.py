from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import User, UserRole, Article, ArticleStatus
from app.utils.auth import hash_password, verify_password, create_token
from app import db
import json

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    """用户注册"""
    try:
        data = request.get_json()
        
        # 检查请求数据是否完整
        if not data or 'username' not in data or 'email' not in data or 'password' not in data:
            return jsonify({'message': '请求数据不完整'}), 400
        
        # 检查用户名是否已存在
        if User.query.filter_by(username=data['username']).first():
            return jsonify({'message': '用户名已存在'}), 400
        
        # 检查邮箱是否已存在
        if User.query.filter_by(email=data['email']).first():
            return jsonify({'message': '邮箱已存在'}), 400
        
        # 创建新用户
        new_user = User(
            username=data['username'],
            email=data['email'],
            password_hash=hash_password(data['password']),
            role=UserRole.user
        )
        
        # 保存到数据库
        db.session.add(new_user)
        db.session.commit()
        
        # 为新注册用户生成token，以便直接登录
        token = create_token(new_user.id, new_user.role)
        
        return jsonify({
            'message': '注册成功',
            'token': token,
            'user_id': new_user.id,
            'username': new_user.username,
            'role': new_user.role.value
        }), 201
    except Exception as e:
        # 发生错误时回滚数据库操作
        db.session.rollback()
        print(f"注册错误: {str(e)}")
        return jsonify({'message': f'注册失败: {str(e)}'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """用户登录"""
    data = request.get_json()
    
    # 查找用户
    user = User.query.filter_by(username=data['username']).first()
    
    # 验证用户和密码
    if not user or not verify_password(data['password'], user.password_hash):
        return jsonify({'message': '用户名或密码错误'}), 401
    
    # 创建token
    token = create_token(user.id, user.role)
    
    return jsonify({
        'token': token,
        'user_id': user.id,
        'username': user.username,
        'role': user.role.value
    }), 200

@auth_bp.route('/users/<int:user_id>', methods=['GET'])
def get_user_info(user_id):
    """获取用户基本信息（公开API）"""
    try:
        user = User.query.get_or_404(user_id)
        
        # 只返回公开信息，不包含敏感数据
        return jsonify({
            'id': user.id,
            'username': user.username,
            'role': user.role.value
        }), 200
    except Exception as e:
        print(f"获取用户信息错误: {str(e)}")
        return jsonify({'message': '获取用户信息失败'}), 500


@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_current_user_profile():
    """获取当前用户的个人资料"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get_or_404(current_user_id)
        
        # 返回完整的用户信息（不包含敏感数据）
        return jsonify({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'role': user.role.value,
            'created_at': user.created_at.isoformat()
        }), 200
    except Exception as e:
        print(f"获取用户资料错误: {str(e)}")
        return jsonify({'message': '获取用户资料失败'}), 500


@auth_bp.route('/profile/articles', methods=['GET'])
@jwt_required()
def get_current_user_articles():
    """获取当前用户的文章和草稿"""
    try:
        current_user_id = get_jwt_identity()
        
        # 获取查询参数
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        status = request.args.get('status')  # 可选：published, draft
        
        # 构建查询
        query = Article.query.filter_by(author_id=current_user_id)
        
        # 如果指定了状态，则过滤
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
        }), 200
    except Exception as e:
        print(f"获取用户文章错误: {str(e)}")
        return jsonify({'message': '获取用户文章失败'}), 500


@auth_bp.route('/profile', methods=['PUT'])
@jwt_required()
def update_current_user_profile():
    """更新当前用户的个人资料"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get_or_404(current_user_id)
        
        data = request.get_json()
        
        # 更新字段
        if 'username' in data:
            # 检查用户名是否已存在
            if User.query.filter_by(username=data['username']).filter(User.id != current_user_id).first():
                return jsonify({'message': '用户名已存在'}), 400
            user.username = data['username']
        
        if 'email' in data:
            # 检查邮箱是否已存在
            if User.query.filter_by(email=data['email']).filter(User.id != current_user_id).first():
                return jsonify({'message': '邮箱已存在'}), 400
            user.email = data['email']
        
        # 保存到数据库
        db.session.commit()
        
        return jsonify({
            'message': '个人资料更新成功',
            'user': {
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'role': user.role.value
            }
        }), 200
    except Exception as e:
        print(f"更新用户资料错误: {str(e)}")
        db.session.rollback()
        return jsonify({'message': '更新用户资料失败'}), 500