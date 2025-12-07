from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token, decode_token

def hash_password(password):
    """对密码进行哈希处理"""
    return generate_password_hash(password)

def verify_password(password, password_hash):
    """验证密码是否正确"""
    return check_password_hash(password_hash, password)

def create_token(user_id, role):
    """创建JWT token"""
    additional_claims = {"role": role.value}
    return create_access_token(identity=str(user_id), additional_claims=additional_claims)

def decode_jwt(token):
    """解码JWT token"""
    return decode_token(token)