# mqtt/mqtt_client.py

import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion
import json
import time
from repository.dev_repository import DevRepository

# ============================================================
# MQTT 配置
# ============================================================
MQTT_BROKER = "154.37.208.239"
MQTT_PORT = 1883
MQTT_KEEPALIVE = 60

SUB_SENSOR_TOPIC = "sensorData"
PUB_CTRL_TOPIC = "devComand"

# ============================================================
# MQTT 客户端初始化（新版本 API）
# ============================================================
mqtt_client = mqtt.Client(callback_api_version=CallbackAPIVersion.VERSION2)
app_ref = None  # 外部注入 flask app


def set_flask_app(app):
    """注入 Flask app 实例"""
    global app_ref
    app_ref = app
    print("✅ Flask app 已注入 MQTT 模块")


# ============================================================
# MQTT 回调函数
# ============================================================
def on_connect(client, userdata, flags, reason_code, properties):
    """连接成功回调"""
    if reason_code == 0:
        print("✅ MQTT 连接成功，订阅传感器主题 sensorData")
        client.subscribe(SUB_SENSOR_TOPIC)
    else:
        print(f"❌ MQTT 连接失败，错误码：{reason_code}")


def on_message(client, userdata, msg):
    """收到消息回调"""
    try:
        payload = msg.payload.decode("utf-8")
        print(f"📥 收到原始数据: {payload}")

        sensor_data = json.loads(payload)

        temp = sensor_data.get("temperature")
        hum = sensor_data.get("humidity")
        light = sensor_data.get("luminance")
        dev_id = sensor_data.get("dev_id", 1)

        print(f"📊 收到硬件数据：温度={temp}℃ 湿度={hum}% 光照={light}Lux")

        # 核心：绑定应用上下文，存入数据库
        if app_ref:
            with app_ref.app_context():
                DevRepository.create(temp, hum, light)
                print(f"💾 数据已存入数据库")
        else:
            print("⚠️ Flask app 未注入，数据未存入数据库")

    except json.JSONDecodeError as e:
        print(f"❌ JSON 解析失败: {e}")
    except Exception as e:
        print(f"❌ 处理传感器数据异常：{e}")


def on_disconnect(client, userdata, reason_code, properties):
    """断开连接回调"""
    print(f"⚠️ MQTT 断开连接，原因码：{reason_code}")

    # 尝试重连
    if reason_code != 0:
        print("🔄 尝试重新连接...")
        try:
            client.connect(MQTT_BROKER, MQTT_PORT, MQTT_KEEPALIVE)
            print("✅ 重连成功")
        except Exception as e:
            print(f"❌ 重连失败: {e}")


def on_publish(client, userdata, mid, reason_code, properties):
    """发布消息回调"""
    print(f"📤 消息发布成功，mid: {mid}")


# ============================================================
# 注册回调函数
# ============================================================
mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message
mqtt_client.on_disconnect = on_disconnect
mqtt_client.on_publish = on_publish


# ============================================================
# 连接 MQTT 服务器
# ============================================================
def connect_mqtt():
    """连接 MQTT 服务器"""
    try:
        mqtt_client.connect(MQTT_BROKER, MQTT_PORT, MQTT_KEEPALIVE)
        mqtt_client.loop_start()
        print(f"🚀 MQTT 连接启动: {MQTT_BROKER}:{MQTT_PORT}")
        return True
    except Exception as e:
        print(f"❌ MQTT 连接失败: {e}")
        return False


# ============================================================
# 下发设备指令（同时支持纯文本和 JSON）
# ============================================================
def send_ctrl_cmd(cmd_str: str):
    """
    下发设备指令到 devComand 主题
    同时发送纯文本和 JSON 两种格式，兼容不同版本的板子

    Args:
        cmd_str: 指令字符串，如 'light_on', 'motor_off', 'auto' 等

    Returns:
        bool: 是否发送成功
    """
    try:
        # 1. 发送纯文本格式（兼容旧版板子）
        result1 = mqtt_client.publish(PUB_CTRL_TOPIC, cmd_str)
        print(f"📤 已下发纯文本指令：{cmd_str}")

        # 2. 发送 JSON 格式（兼容新版板子）
        json_payload = json.dumps({
            "command": cmd_str,
            "timestamp": time.strftime('%Y-%m-%d %H:%M:%S')
        })
        result2 = mqtt_client.publish(PUB_CTRL_TOPIC, json_payload)
        print(f"📤 已下发 JSON 指令：{json_payload}")

        return True
    except Exception as e:
        print(f"❌ 下发指令失败：{e}")
        return False


def send_ctrl_cmd_json(cmd_str: str):
    """
    仅发送 JSON 格式指令（纯 JSON 模式）

    Args:
        cmd_str: 指令字符串

    Returns:
        bool: 是否发送成功
    """
    try:
        payload = json.dumps({
            "command": cmd_str,
            "timestamp": time.strftime('%Y-%m-%d %H:%M:%S')
        })
        result = mqtt_client.publish(PUB_CTRL_TOPIC, payload)
        print(f"📤 已下发 JSON 指令：{payload}")
        return True
    except Exception as e:
        print(f"❌ 下发指令失败：{e}")
        return False


def send_ctrl_cmd_text(cmd_str: str):
    """
    仅发送纯文本指令（纯文本模式）

    Args:
        cmd_str: 指令字符串

    Returns:
        bool: 是否发送成功
    """
    try:
        result = mqtt_client.publish(PUB_CTRL_TOPIC, cmd_str)
        print(f"📤 已下发纯文本指令：{cmd_str}")
        return True
    except Exception as e:
        print(f"❌ 下发指令失败：{e}")
        return False


def send_device_control(device: str, action: str):
    """
    发送设备控制指令（由 AI 接口调用）

    Args:
        device: 设备名称，如 'light', 'buzzer', 'motor', 'pump'
        action: 动作，如 'on', 'off'

    Returns:
        bool: 是否发送成功
    """
    print(f"📤 设备控制请求: {device} -> {action}")

    # 设备指令映射表（板子识别的指令格式）
    cmd_map = {
        '补光灯': {'打开': 'light_on', '关闭': 'light_off'},
        'light': {'on': 'light_on', 'off': 'light_off'},

        '蜂鸣器': {'打开': 'beer_on', '关闭': 'beer_off'},
        'buzzer': {'on': 'beer_on', 'off': 'beer_off'},
        'beer': {'on': 'beer_on', 'off': 'beer_off'},

        '电机': {'打开': 'motor_on', '关闭': 'motor_off'},
        'motor': {'on': 'motor_on', 'off': 'motor_off'},

        '水泵': {'打开': 'motor_on', '关闭': 'motor_off'},  # 水泵复用电机指令
        'pump': {'on': 'motor_on', 'off': 'motor_off'},

        '风扇': {'打开': 'fan_on', '关闭': 'fan_off'},
        'fan': {'on': 'fan_on', 'off': 'fan_off'},
    }

    # 查找指令
    if device in cmd_map and action in cmd_map[device]:
        cmd_str = cmd_map[device][action]
        print(f"📤 映射指令: {device} {action} -> '{cmd_str}'")
        return send_ctrl_cmd(cmd_str)  # 同时发送纯文本和 JSON
    else:
        # 尝试模糊匹配
        for key in cmd_map:
            if device in key or key in device:
                if action in cmd_map[key]:
                    cmd_str = cmd_map[key][action]
                    print(f"📤 模糊匹配: {device} -> {key} {action} -> '{cmd_str}'")
                    return send_ctrl_cmd(cmd_str)

        print(f"❌ 未知设备或指令: device={device}, action={action}")
        return False


def send_mode_change(mode: str):
    """
    发送控制模式切换指令

    Args:
        mode: 模式名称，'auto' 或 'manual'

    Returns:
        bool: 是否发送成功
    """
    mode_map = {
        'auto': 'auto',
        'automatic': 'auto',
        '自动': 'auto',
        '自动模式': 'auto',
        'manual': 'handle',
        '手动': 'handle',
        '手动模式': 'handle'
    }

    if mode in mode_map:
        cmd_str = mode_map[mode]
        print(f"🔄 切换模式: {mode} -> '{cmd_str}'")
        return send_ctrl_cmd(cmd_str)
    else:
        print(f"❌ 未知模式: {mode}")
        return False


# ============================================================
# 订阅自定义主题
# ============================================================
def subscribe_topic(topic: str):
    """订阅自定义主题"""
    try:
        mqtt_client.subscribe(topic)
        print(f"📡 已订阅主题: {topic}")
        return True
    except Exception as e:
        print(f"❌ 订阅失败: {e}")
        return False


def unsubscribe_topic(topic: str):
    """取消订阅主题"""
    try:
        mqtt_client.unsubscribe(topic)
        print(f"📡 已取消订阅: {topic}")
        return True
    except Exception as e:
        print(f"❌ 取消订阅失败: {e}")
        return False


# ============================================================
# 发布自定义消息
# ============================================================
def publish_message(topic: str, message: str):
    """发布自定义消息"""
    try:
        result = mqtt_client.publish(topic, message)
        print(f"📤 已发布消息到 {topic}: {message}")
        return True
    except Exception as e:
        print(f"❌ 发布失败: {e}")
        return False


# ============================================================
# 断开 MQTT 连接
# ============================================================
def disconnect_mqtt():
    """断开 MQTT 连接"""
    try:
        mqtt_client.loop_stop()
        mqtt_client.disconnect()
        print("🔌 MQTT 已断开连接")
        return True
    except Exception as e:
        print(f"❌ 断开连接失败: {e}")
        return False


# ============================================================
# 启动 MQTT（模块加载时自动连接）
# ============================================================
print("=" * 50)
print("📡 MQTT 模块初始化")
print(f"   Broker: {MQTT_BROKER}:{MQTT_PORT}")
print(f"   订阅主题: {SUB_SENSOR_TOPIC}")
print(f"   发布主题: {PUB_CTRL_TOPIC}")
print("=" * 50)

# 自动连接
connect_mqtt()