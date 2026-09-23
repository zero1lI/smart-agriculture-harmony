import requests
from flask import Blueprint, request, jsonify

weather_bp = Blueprint('weather', __name__)

HEFENG_API_KEY = 'ca997bf0c7684406a8bf32124a8bc77f'
WEATHER_NOW_URL = 'https://nu4ewv7pqa.re.qweatherapi.com/v7/weather/now'
WEATHER_FORECAST_URL = 'https://devapi.qweather.com/v7/weather/3d'
AIR_URL = 'https://devapi.qweather.com/v7/air/now'

# 常用城市ID映射，直接查不用调地理API
CITY_ID_MAP = {
    '北京': '101010101',
    '上海': '101020100',
    '广州': '101280101',
    '深圳': '101280601',
    '呼和浩特': '101080101',
    '天津': '101030100',
    '成都': '101270101',
    '杭州': '101210101',
    '南京': '101190101',
    '武汉': '101200101',
}


def get_location_id(city_name):
    # 先从映射表里找
    if city_name in CITY_ID_MAP:
        return CITY_ID_MAP[city_name]
    return None  # 找不到就返回空，后续可以再加地理API兜底


@weather_bp.route('/api/weather/now', methods=['GET'])
def get_weather_now():
    city = request.args.get('city', '北京')
    location_id = get_location_id(city)

    if not location_id:
        return jsonify({'code': 400, 'message': f'暂不支持城市: {city}，请先用常用城市测试'})

    params = {'location': location_id, 'key': HEFENG_API_KEY}
    try:
        resp = requests.get(WEATHER_NOW_URL, params=params, timeout=10)
        print(f'[调试] 天气API状态码: {resp.status_code}')
        print(f'[调试] 天气API返回内容: {resp.text[:300]}')
        data = resp.json()
        if data.get('code') == '200':
            now = data['now']
            return jsonify({
                'code': 200,
                'message': '获取成功',
                'data': {
                    'city': city,
                    'temp': now.get('temp'),
                    'feelsLike': now.get('feelsLike'),
                    'text': now.get('text'),
                    'windDir': now.get('windDir'),
                    'windScale': now.get('windScale'),
                    'humidity': now.get('humidity'),
                }
            })
        else:
            return jsonify({'code': 500, 'message': f'天气API错误: {data.get("msg")}'})
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)})