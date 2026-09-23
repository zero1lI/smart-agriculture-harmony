from flask import Blueprint, request, jsonify
from mqtt.mqtt_client import send_ctrl_cmd
from repository.dev_repository import DevRepository

device_bp = Blueprint("device", __name__, url_prefix="/api")


# ============================================================
# ⚠️ 注意：/api/ai/send 路由已移至 app.py 中统一管理
# 请勿在此处重复定义，否则会造成路由冲突！
# ============================================================

# ============================================================
# 设备控制接口（GET 方式）
# ============================================================
@device_bp.route("/device/control", methods=["GET"])
def light_ctrl():
    """
    下发设备控制指令
    使用方式: GET /api/device/control?action=light_on
    """
    action = request.args.get("action")

    if not action:
        return jsonify({
            "code": 400,
            "msg": "缺少 action 参数",
            "data": None
        })

    # 发送到 MQTT
    success = send_ctrl_cmd(action)

    if success:
        return jsonify({
            "code": 200,
            "msg": f"指令 {action} 下发成功",
            "cmd": action,
            "data": {
                "action": action,
                "status": "sent"
            }
        })
    else:
        return jsonify({
            "code": 500,
            "msg": f"指令 {action} 下发失败",
            "cmd": action,
            "data": None
        })


# ============================================================
# 设备控制接口（POST 方式，兼容 JSON）
# ============================================================
@device_bp.route("/device/control", methods=["POST"])
def light_ctrl_post():
    """
    下发设备控制指令（POST 方式）
    使用方式: POST /api/device/control
    Body: {"device": "light", "action": "on"}
    """
    try:
        data = request.get_json()

        # 兼容两种参数格式
        device = data.get('device')
        action = data.get('action')

        if not action:
            return jsonify({
                "code": 400,
                "msg": "缺少 action 参数",
                "data": None
            })

        # 构建设备指令
        cmd_map = {
            'light': {'on': 'light_on', 'off': 'light_off'},
            'buzzer': {'on': 'beer_on', 'off': 'beer_off'},
            'motor': {'on': 'motor_on', 'off': 'motor_off'},
            'pump': {'on': 'motor_on', 'off': 'motor_off'},
            'fan': {'on': 'fan_on', 'off': 'fan_off'},
        }

        # 如果传了 device，映射为具体指令
        if device and device in cmd_map and action in cmd_map[device]:
            cmd_str = cmd_map[device][action]
        else:
            cmd_str = action  # 直接使用 action 作为指令

        # 发送到 MQTT
        success = send_ctrl_cmd(cmd_str)

        if success:
            return jsonify({
                "code": 200,
                "msg": f"指令 {cmd_str} 下发成功",
                "data": {
                    "device": device,
                    "action": action,
                    "cmd": cmd_str,
                    "status": "sent"
                }
            })
        else:
            return jsonify({
                "code": 500,
                "msg": f"指令 {cmd_str} 下发失败",
                "data": None
            })

    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"控制失败: {str(e)}",
            "data": None
        })


# ============================================================
# 获取最新传感器数据
# ============================================================
@device_bp.route("/data/latest", methods=["GET"])
def get_latest_sensor():
    """
    获取最新传感器数据
    使用方式: GET /api/data/latest
    """
    try:
        record = DevRepository.get_order_by_latest()
        if not record:
            return jsonify({
                "code": 400,
                "msg": "暂无传感器数据",
                "data": None
            })
        return jsonify({
            "code": 200,
            "msg": "查询成功",
            "data": record.to_dict()
        })
    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"查询失败: {str(e)}",
            "data": None
        })


# ============================================================
# 获取历史传感器数据（可选）
# ============================================================
@device_bp.route("/data/history", methods=["GET"])
def get_sensor_history():
    """
    获取历史传感器数据
    使用方式: GET /api/data/history?limit=10
    """
    try:
        limit = request.args.get("limit", 10, type=int)
        records = DevRepository.get_order_by_latest(limit=limit)

        if not records:
            return jsonify({
                "code": 400,
                "msg": "暂无历史数据",
                "data": []
            })

        data_list = [record.to_dict() for record in records]
        return jsonify({
            "code": 200,
            "msg": "查询成功",
            "data": data_list
        })
    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"查询失败: {str(e)}",
            "data": None
        })


# ============================================================
# 设备状态查询（可选）
# ============================================================
@device_bp.route("/device/status", methods=["GET"])
def get_device_status():
    """
    获取设备状态
    使用方式: GET /api/device/status
    """
    try:
        # 这里可以从数据库或 MQTT 获取设备状态
        # 目前返回模拟状态
        return jsonify({
            "code": 200,
            "msg": "设备状态查询成功",
            "data": {
                "light": "off",
                "buzzer": "off",
                "motor": "off",
                "fan": "off",
                "pump": "off"
            }
        })
    except Exception as e:
        return jsonify({
            "code": 500,
            "msg": f"查询失败: {str(e)}",
            "data": None
        })