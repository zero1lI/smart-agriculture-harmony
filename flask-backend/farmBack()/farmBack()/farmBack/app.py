from flask import Flask, request, jsonify
from flask_cors import CORS
from extensions import db
from controllers.user_controller import user_bp
from controllers.device_controller import device_bp
from controllers.device_control_controller import device_ctrl_bp
from mqtt.mqtt_client import set_flask_app
from utils.weather_blueprint import weather_bp
import json
import traceback

# 1. 创建flask对象
app = Flask(__name__)

# 2. 全局中文乱码配置
app.config['JSON_AS_ASCII'] = False
app.config['JSONIFY_MIMETYPE'] = 'application/json;charset=utf-8'

# 3. 数据库配置
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:zpf900619@154.37.208.239:3306/10group?charset=utf8mb4'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# 4. 初始化数据库
db.init_app(app)

# 5. 跨域
CORS(app)

# 6. 注册蓝图
app.register_blueprint(user_bp)
app.register_blueprint(device_bp)
app.register_blueprint(weather_bp)
app.register_blueprint(device_ctrl_bp)

# 7. 将当前app实例注入MQTT模块
set_flask_app(app)

# 8. 自动创建数据表
with app.app_context():
    db.create_all()


# ============================================================
# ============ AI 对话接口 ====================================
# ============================================================
@app.route('/api/ai/send', methods=['GET', 'POST'])
def ai_send():
    """MaxKB 调用的 AI 对话接口"""
    # 获取 query 参数
    if request.method == 'GET':
        query = request.args.get('query', '')
    else:
        query = request.json.get('query', '') if request.json else ''

    print(f"🤖 收到 AI 查询: {query}")

    if not query:
        return jsonify({
            'code': 400,
            'message': 'query 参数不能为空',
            'data': None
        })

    try:
        # 解析命令并执行
        result = process_ai_command(query)
        print(f"📤 返回结果: {result}")

        # ===== 关键：确保返回 data 字段 =====
        return jsonify({
            'code': 200,
            'message': 'success',
            'data': result
        })
    except Exception as e:
        print(f"❌ 处理异常: {str(e)}")
        traceback.print_exc()
        return jsonify({
            'code': 500,
            'message': f'处理异常: {str(e)}',
            'data': None
        })


def process_ai_command(query: str):
    """解析 AI 命令并调用对应的控制函数"""
    query_lower = query.lower()
    print(f"🔍 解析命令: {query_lower}")

    # 设备名称映射
    device_map = {
        '补光灯': 'light',
        '灯': 'light',
        '照明': 'light',
        '蜂鸣器': 'buzzer',
        '蜂鸣': 'buzzer',
        '电机': 'motor',
        '马达': 'motor',
        '水泵': 'pump',
        '泵': 'pump',
        '风扇': 'fan',
        '风机': 'fan',
    }

    # 1. 打开设备
    if '打开' in query_lower:
        for device_name, device_id in device_map.items():
            if device_name in query_lower:
                print(f"💡 执行: 打开 {device_name} ({device_id})")
                return control_device(device_id, 'on')
        # 如果没匹配到具体设备
        return {
            'action': 'unknown',
            'status': 'error',
            'message': f'未识别要打开的设备: "{query}"'
        }

    # 2. 关闭设备
    elif '关闭' in query_lower:
        for device_name, device_id in device_map.items():
            if device_name in query_lower:
                print(f"💡 执行: 关闭 {device_name} ({device_id})")
                return control_device(device_id, 'off')
        return {
            'action': 'unknown',
            'status': 'error',
            'message': f'未识别要关闭的设备: "{query}"'
        }

    # 3. 查询设备状态
    elif '状态' in query_lower or '查询' in query_lower:
        print("📊 执行: 查询状态")
        return get_device_status()

    # 4. 未知命令
    else:
        return {
            'action': 'unknown',
            'status': 'error',
            'message': f'未识别的指令: "{query}"，请尝试：打开补光灯、关闭补光灯、查询状态'
        }


def control_device(device_name: str, action: str):
    """控制设备"""
    print(f"📤 控制设备: {device_name} -> {action}")

    try:
        with app.test_client() as client:
            response = client.post('/api/device/control',
                                   json={
                                       'device': device_name,
                                       'action': action
                                   },
                                   headers={'Content-Type': 'application/json'}
                                   )

            print(f"📤 设备控制响应状态: {response.status_code}")
            print(f"📤 设备控制响应内容: {response.data.decode('utf-8')[:200]}")

            if response.status_code == 200:
                try:
                    data = response.json
                    return {
                        'action': 'device_control',
                        'status': 'success',
                        'device': device_name,
                        'action_taken': action,
                        'message': f'{device_name} 已{action}',
                        'response': data
                    }
                except:
                    return {
                        'action': 'device_control',
                        'status': 'success',
                        'device': device_name,
                        'action_taken': action,
                        'message': f'{device_name} 已{action}',
                        'response': response.data.decode('utf-8')
                    }
            else:
                return {
                    'action': 'device_control',
                    'status': 'error',
                    'device': device_name,
                    'message': f'控制失败: HTTP {response.status_code}',
                    'detail': response.data.decode('utf-8')[:200]
                }

    except Exception as e:
        print(f"❌ 控制异常: {str(e)}")
        traceback.print_exc()
        return {
            'action': 'device_control',
            'status': 'error',
            'device': device_name,
            'message': f'控制异常: {str(e)}'
        }


def get_device_status():
    """获取设备状态"""
    print("📊 查询设备状态")

    try:
        with app.test_client() as client:
            response = client.get('/api/device/status')

            if response.status_code == 200:
                try:
                    data = response.json
                    return {
                        'action': 'status_query',
                        'status': 'success',
                        'message': '设备状态查询成功',
                        'devices': data
                    }
                except:
                    return {
                        'action': 'status_query',
                        'status': 'success',
                        'message': '设备状态查询成功',
                        'devices': response.data.decode('utf-8')
                    }
            else:
                return {
                    'action': 'status_query',
                    'status': 'error',
                    'message': f'查询失败: HTTP {response.status_code}'
                }
    except Exception as e:
        return {
            'action': 'status_query',
            'status': 'error',
            'message': f'查询异常: {str(e)}'
        }


# ============================================================
# ============ 测试路由 ========================================
# ============================================================
@app.route('/api/ai/test', methods=['GET'])
def ai_test():
    """测试 AI 接口是否正常"""
    return jsonify({
        'code': 200,
        'message': 'AI 接口正常运行',
        'endpoints': [
            'GET /api/ai/send?query=打开补光灯',
            'GET /api/ai/send?query=关闭补光灯',
            'GET /api/ai/send?query=打开蜂鸣器',
            'GET /api/ai/send?query=关闭蜂鸣器',
            'GET /api/ai/send?query=查询状态'
        ]
    })


# main入口
if __name__ == '__main__':
    print("=" * 60)
    print("🚀 Flask AI 服务启动")
    print("=" * 60)
    app.run(host="0.0.0.0", port=8080, debug=True)