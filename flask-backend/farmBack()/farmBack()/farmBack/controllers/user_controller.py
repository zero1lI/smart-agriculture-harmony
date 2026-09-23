from flask import Blueprint, request, jsonify
from repository.user_repository import UserRepository

# 创建蓝图
user_bp = Blueprint('user', __name__, url_prefix='/api/user')

# ==================== 1. 查询所有用户 ====================
@user_bp.route('/', methods=['GET'])
def get_all_users():
    """
    获取所有用户列表
    GET /api/users/
    """
    users = UserRepository.get_all()

    return jsonify({
        'code': 200,
        'message': '获取成功',
        'data': [user.to_dict() for user in users],
        'total': len(users)
    })

# ==================== 用户登录 ====================
@user_bp.route('/login', methods=['GET'])
def get_user_login():
    """
    获取所有用户列表
    GET /api/users/
    """
    phone=request.args.get("phone")
    password = request.args.get("password")
    # 根据手机号与密码从数据库中查询该用户是否存在
    user=UserRepository.get_by_phone_password(phone,password)
    # 判断
    if not user:
        return jsonify({
            'code': 400,
            'message': '手机号或者密码错误'
        })

    return jsonify({
        'code': 200,
        'message': '登录成功',
        'data': user.to_dict(),
    })
# ==================== 2. 根据ID查询用户 ====================
@user_bp.route('/<int:user_id>', methods=['GET'])
def get_user_by_id(user_id):
    """
    根据ID获取用户信息
    GET /api/users/1
    """
    user = UserRepository.get_by_id(user_id)
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404

    return jsonify({
        'code': 200,
        'message': '获取成功',
        'data': user.to_dict()
    })


# ==================== 3. 创建用户（注册） ====================
@user_bp.route('/register', methods=['POST'])
def create_user():
    """
    创建用户
    POST /api/users/
    """
    data = request.get_json()
    # 检查用户名是否已存在
    existing_user = UserRepository.get_by_username(data.get('username'))
    if existing_user:
        return jsonify({
            'code': 400,
            'message': '用户名已存在'
        })

    # 检查邮箱是否已存在
    existing_email = UserRepository.get_by_email(data.get('email'))
    if existing_email:
        return jsonify({
            'code': 400,
            'message': '邮箱已存在'
        })

    # 检查手机号是否已存在
    existing_phone = UserRepository.get_by_phone(data.get('phone'))
    if existing_phone:
        return jsonify({
            'code': 400,
            'message': '手机号已存在'
        })

    # 创建用户
    user = UserRepository.create(
        username=data.get('username'),
        password=data.get('password'),
        email=data.get('email'),
        phone=data.get('phone')
    )

    return jsonify({
        'code': 200,
        'message': '创建成功',
        'data': user.to_dict()
    })

# ==================== 4. 更新用户信息 ====================
@user_bp.route('/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    """
    更新用户信息
    PUT /api/users/1
    Body: {
        "username": "new_name",
        "email": "new@email.com",
        "phone": "13900139000"
    }
    """
    data = request.get_json()

    if not data:
        return jsonify({
            'code': 400,
            'message': '请求数据不能为空'
        }), 400

    # 检查用户是否存在
    user = UserRepository.get_by_id(user_id)
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404

    # 如果要更新用户名，检查是否已被占用
    new_username = data.get('username')
    if new_username and new_username != user.username:
        existing_user = UserRepository.get_by_username(new_username)
        if existing_user:
            return jsonify({
                'code': 400,
                'message': '用户名已被占用'
            }), 400

    # 更新用户
    updated_user = UserRepository.update(user_id, **data)

    return jsonify({
        'code': 200,
        'message': '更新成功',
        'data': updated_user.to_dict()
    })


# ==================== 5. 部分更新用户信息 ====================
@user_bp.route('/<int:user_id>', methods=['PATCH'])
def patch_user(user_id):
    """
    部分更新用户信息（只更新传入的字段）
    PATCH /api/users/1
    Body: {
        "email": "new@email.com"  # 只更新这一个字段
    }
    """
    data = request.get_json()

    if not data:
        return jsonify({
            'code': 400,
            'message': '请求数据不能为空'
        }), 400

    # 检查用户是否存在
    user = UserRepository.get_by_id(user_id)
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404

    # 部分更新
    updated_user = UserRepository.update(user_id, **data)

    return jsonify({
        'code': 200,
        'message': '更新成功',
        'data': updated_user.to_dict()
    })


# ==================== 6. 删除用户 ====================
@user_bp.route('/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    """
    删除用户
    DELETE /api/users/1
    """
    # 检查用户是否存在
    user = UserRepository.get_by_id(user_id)
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404

    # 删除用户
    UserRepository.delete(user_id)

    return jsonify({
        'code': 200,
        'message': '删除成功'
    })


# ==================== 7. 根据用户名搜索用户 ====================
@user_bp.route('/search', methods=['GET'])
def search_users():
    """
    搜索用户（根据用户名模糊查询）
    GET /api/users/search?username=zpf
    """
    username = request.args.get('username')

    if not username:
        return jsonify({
            'code': 400,
            'message': '请输入搜索关键词'
        }), 400

    users = UserRepository.search(username)

    return jsonify({
        'code': 200,
        'message': '搜索成功',
        'data': [user.to_dict() for user in users],
        'total': len(users)
    })


# ==================== 8. 分页查询用户 ====================
@user_bp.route('/page', methods=['GET'])
def get_users_by_page():
    """
    分页查询用户
    GET /api/users/page?page=1&size=10
    """
    page = request.args.get('page', 1, type=int)
    size = request.args.get('size', 10, type=int)

    if page < 1:
        page = 1
    if size < 1:
        size = 10

    result = UserRepository.paginate(page, size)

    return jsonify({
        'code': 200,
        'message': '获取成功',
        'data': [user.to_dict() for user in result.items],
        'total': result.total,
        'page': page,
        'size': size,
        'pages': result.pages
    })