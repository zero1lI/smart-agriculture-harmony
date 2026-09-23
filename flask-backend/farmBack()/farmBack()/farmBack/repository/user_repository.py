from typing import Optional,List
from models.user import User
from extensions import db

class UserRepository:
    """用户数据访问层 - 负责数据库操作"""
    @staticmethod
    def get_by_id(user_id) -> Optional[User]:
        """根据ID查询"""
        return User.query.get(user_id)

    @staticmethod
    def get_by_phone_password(phone,password) -> Optional[User]:
        """根据手机号与密码查询"""
        return User.query.filter_by(phone=phone,password=password).first()

    @staticmethod
    def get_by_username(username) -> Optional[User]:
        """根据用户名查询"""
        return User.query.filter_by(username=username).first()

    @staticmethod
    def get_by_email(email) -> Optional[User]:
        """根据邮箱查询"""
        return User.query.filter_by(email=email).first()

    @staticmethod
    def get_by_phone(phone) -> Optional[User]:
        """根据手机查询"""
        return User.query.filter_by(phone=phone).first()

    @staticmethod
    def get_all() -> List[User]:
        """查询所有用户"""
        return User.query.all()

    @staticmethod
    def create(username, password, email=None, phone=None):
        """创建用户"""
        user = User(
            username=username,
            password=password,
            email=email,
            phone=phone
        )
        db.session.add(user)
        db.session.commit()
        return user

    @staticmethod
    def update(user_id, **kwargs):
        """更新用户"""
        user = User.query.get(user_id)
        if not user:
            return None

        for key, value in kwargs.items():
            if hasattr(user, key):
                setattr(user, key, value)

        db.session.commit()
        return user

    @staticmethod
    def delete(user_id):
        """删除用户"""
        user = User.query.get(user_id)
        if not user:
            return False
        db.session.delete(user)
        db.session.commit()
        return True