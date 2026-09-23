# models/environment.py
from datetime import datetime
from extensions import db

class Dev(db.Model):
    """农田环境传感器数据表"""
    __tablename__ = 'devData'
    dev_id = db.Column(db.Integer, primary_key=True, autoincrement=True, comment="设备ID")
    temperature = db.Column(db.Float, comment="温度")
    humidity = db.Column(db.Float, comment="湿度")
    luminance = db.Column(db.Float, comment="光照强度")
    times = db.Column(db.DateTime, default=datetime.now, comment="采集时间")

    def to_dict(self):
        """模型转字典，用于接口返回json"""
        return {
            'dev_id': self.dev_id,
            'temperature': self.temperature,
            'humidity': self.humidity,
            'luminance': self.luminance,
            'times': self.times.strftime('%Y-%m-%d %H:%M:%S') if self.times else None
        }

    def __str__(self):
        return f'EnvironmentData(dev_id={self.dev_id},temperature={self.temperature}, humidity={self.humidity},luminance={self.luminance}, times={self.times})'