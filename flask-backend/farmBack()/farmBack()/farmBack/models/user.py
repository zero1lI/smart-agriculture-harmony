# models/user.py
from datetime import datetime
# 操作数据库的对象
from extensions import db

class User(db.Model):

    """用户实体类 - 只定义数据结构"""
    __tablename__ = 'userInfo'
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True)
    phone = db.Column(db.String(100), unique=True)
    times = db.Column(db.DateTime, default=datetime.now)

    def to_dict(self):
        """转换为字典（数据转换，属于 Model）"""
        return {
            'user_id': self.user_id,
            'username': self.username,
            'password': self.password,
            'email': self.email,
            'phone': self.phone,
            'times': self.times.strftime('%Y-%m-%d %H:%M:%S') if self.times else None
        }

    def __str__(self):
        return f'User(user_id={self.user_id},username={self.username}, password={self.password},email={self.email}, phone={self.phone})'
