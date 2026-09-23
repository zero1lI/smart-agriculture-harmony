from typing import Optional,List
from models.dev import Dev
from extensions import db

class DevRepository:

    @staticmethod
    def get_order_by_latest() -> Optional[Dev]:
        """根据设备ID查询最新的数据"""
        return Dev.query.order_by(Dev.dev_id.desc()).first()

    @staticmethod
    def get_all() -> List[Dev]:
        """查询所有设备数据"""
        return Dev.query.all()

    @staticmethod
    def create(temp, hum, light):
        """创建用户"""
        dev = Dev(
            temperature=temp,
            humidity=hum,
            luminance=light
        )
        db.session.add(dev)
        db.session.commit()
        return dev

