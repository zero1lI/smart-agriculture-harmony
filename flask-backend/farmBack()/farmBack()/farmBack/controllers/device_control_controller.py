# controllers/device_control_controller.py

from flask import Blueprint, request, jsonify
import json
import time
from mqtt.mqtt_client import send_device_control, send_mode_change

# 创建设备控制蓝图
device_ctrl_bp = Blueprint('device_ctrl', __name__)

# ============================================================
# 设备状态存储（用于模拟/内存存储）
# ============================================================
# 实际项目中可以用数据库替代
device_states = {
    '补光灯': '关闭',
    '蜂鸣器': '关闭',
    '风扇': '关闭',
    '水泵': '关闭'
}


# ============================================================
# 设备控制接口
# ============================================================
@device_ctrl_bp.route('/api/device/control', methods=['POST'])
def device_control():
    """设备控制接口"""
    try:
        data = request.get_json()

        # 兼容两种参数格式
        device = data.get('device') or data.get('device_name')
        action = data.get('action')
        greenhouse = data.get('greenhouse', 'default')

        if not device or not action:
            return jsonify({
                'code': 400,
                'message': '缺少必要参数: device 和 action',
                'data': None
            })

        print(f"📱 收到控制指令 - 大棚:{greenhouse}, 设备:{device}, 动作:{action}")

        # 方式1: 通过 MQTT 发送控制指令
        success = send_device_control(device, action)

        if success:
            # 更新内存状态
            device_states[device] = action

            return jsonify({
                'code': 200,
                'message': f'{device} {action} 指令已发送',
                'data': {
                    'device': device,
                    'action': action,
                    'greenhouse': greenhouse,
                    'state': device_states[device],
                    'method': 'mqtt'
                }
            })
        else:
            # 方式2: MQTT 发送失败，使用模拟控制（开发测试用）
            print(f"⚠️ MQTT 发送失败，使用模拟控制: {device} -> {action}")
            device_states[device] = action

            return jsonify({
                'code': 200,
                'message': f'[模拟] {device} 已{action}',
                'data': {
                    'device': device,
                    'action': action,
                    'greenhouse': greenhouse,
                    'state': device_states[device],
                    'method': 'simulation',
                    'note': 'MQTT 服务未连接，使用模拟模式'
                }
            })

    except Exception as e:
        print(f"❌ 设备控制失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'code': 500,
            'message': f'控制失败: {str(e)}',
            'data': None
        })


# ============================================================
# 获取设备状态接口
# ============================================================
@device_ctrl_bp.route('/api/device/status', methods=['GET'])
def get_device_status():
    """获取所有设备状态"""
    try:
        greenhouse = request.args.get('greenhouse', 'default')

        print(f"📊 查询设备状态 - 大棚:{greenhouse}")

        # 这里可以从数据库或 MQTT 获取实时状态
        # 目前返回内存中的状态

        return jsonify({
            'code': 200,
            'message': '设备状态查询成功',
            'data': {
                'greenhouse': greenhouse,
                'devices': device_states,
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
            }
        })

    except Exception as e:
        print(f"❌ 查询设备状态失败: {str(e)}")
        return jsonify({
            'code': 500,
            'message': f'查询失败: {str(e)}',
            'data': None
        })


# ============================================================
# 获取单个设备状态
# ============================================================
@device_ctrl_bp.route('/api/device/status/<device_name>', methods=['GET'])
def get_device_status_by_name(device_name):
    """获取单个设备状态"""
    try:
        if device_name not in device_states:
            return jsonify({
                'code': 404,
                'message': f'设备 "{device_name}" 不存在',
                'data': None
            })

        return jsonify({
            'code': 200,
            'message': '设备状态查询成功',
            'data': {
                'device': device_name,
                'state': device_states.get(device_name, '未知'),
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
            }
        })

    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'查询失败: {str(e)}',
            'data': None
        })


# ============================================================
# 控制模式切换接口
# ============================================================
@device_ctrl_bp.route('/api/mode/change', methods=['POST'])
def mode_change():
    """控制模式切换接口"""
    try:
        data = request.get_json()
        mode = data.get('mode')
        greenhouse = data.get('greenhouse', 'default')

        if not mode:
            return jsonify({
                'code': 400,
                'message': '缺少必要参数: mode'
            })

        print(f"🔄 切换控制模式 - 大棚:{greenhouse}, 模式:{mode}")

        # 发送模式切换指令
        success = send_mode_change(mode)

        if success:
            return jsonify({
                'code': 200,
                'message': f'已切换至 {mode} 模式',
                'data': {
                    'mode': mode,
                    'greenhouse': greenhouse,
                    'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
                }
            })
        else:
            # 模拟模式切换
            print(f"⚠️ MQTT 发送失败，使用模拟模式切换: {mode}")
            return jsonify({
                'code': 200,
                'message': f'[模拟] 已切换至 {mode} 模式',
                'data': {
                    'mode': mode,
                    'greenhouse': greenhouse,
                    'method': 'simulation',
                    'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
                }
            })

    except Exception as e:
        print(f"❌ 模式切换失败: {str(e)}")
        return jsonify({
            'code': 500,
            'message': f'模式切换失败: {str(e)}',
            'data': None
        })


# ============================================================
# 批量控制设备
# ============================================================
@device_ctrl_bp.route('/api/device/batch', methods=['POST'])
def batch_device_control():
    """批量控制设备"""
    try:
        data = request.get_json()
        devices = data.get('devices', [])
        greenhouse = data.get('greenhouse', 'default')

        if not devices:
            return jsonify({
                'code': 400,
                'message': '缺少必要参数: devices'
            })

        print(f"📱 批量控制 - 大棚:{greenhouse}, 设备数:{len(devices)}")

        results = []
        success_count = 0

        for item in devices:
            device = item.get('device')
            action = item.get('action')

            if device and action:
                success = send_device_control(device, action)
                if success:
                    device_states[device] = action
                    success_count += 1
                results.append({
                    'device': device,
                    'action': action,
                    'success': success
                })

        return jsonify({
            'code': 200,
            'message': f'批量控制完成，成功 {success_count}/{len(devices)} 个设备',
            'data': {
                'greenhouse': greenhouse,
                'total': len(devices),
                'success_count': success_count,
                'results': results
            }
        })

    except Exception as e:
        print(f"❌ 批量控制失败: {str(e)}")
        return jsonify({
            'code': 500,
            'message': f'批量控制失败: {str(e)}',
            'data': None
        })


# ============================================================
# 重置设备状态（测试用）
# ============================================================
@device_ctrl_bp.route('/api/device/reset', methods=['POST'])
def reset_devices():
    """重置所有设备状态（测试用）"""
    try:
        for device in device_states:
            device_states[device] = '关闭'

        return jsonify({
            'code': 200,
            'message': '所有设备已重置为关闭状态',
            'data': {
                'devices': device_states,
                'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
            }
        })

    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'重置失败: {str(e)}',
            'data': None
        })