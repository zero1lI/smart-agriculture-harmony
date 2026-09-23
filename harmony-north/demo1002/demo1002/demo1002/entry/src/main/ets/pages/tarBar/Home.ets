// tarBar/Home.ets
import { http } from '@kit.NetworkKit';
import { FloatingBall } from '../../modules/FloatingBall';

// 轮播图数据接口
interface SwiperItem {
  image: Resource;
  title: string;
  desc: string;
}

// 后台返回的设备数据接口
interface DevData {
  code: number,
  data: DevType,
  message: string
}

interface DevType {
  dev_id: number,
  humidity: number,
  luminance: number,
  temperature: number,
  times: string
}

// 天气API返回数据接口（和风天气）
interface WeatherData {
  city: string;
  feelsLike: string;
  humidity: string;
  temp: string;
  text: string;
  windDir: string;
  windScale: string;
}

interface WeatherApiResponse {
  code: number,
  data: WeatherData,
  message: string
}

// 天气数据类型
interface WeatherType {
  city: string,
  outdoorTemp: number,
  feelsLike: number,
  outdoorHumidity: number,
  windDir: string,
  windScale: string,
  weatherDesc: string,
  weatherIcon: string
}

@Component
export struct Home {
  // 轮播图当前索引
  @State currentBannerIndex: number = 0;

  // ========== 动态数据 - 从后台获取 ==========
  @State temperature: number = 0;
  @State humidity: number = 0;
  @State lightIntensity: number = 0;
  @State updateTime: string = '加载中...';
  @State isOnline: boolean = false;

  // ========== 天气数据 ==========
  @State weatherData: WeatherType = {
    city: '加载中...',
    outdoorTemp: 0,
    feelsLike: 0,
    outdoorHumidity: 0,
    windDir: '--',
    windScale: '--',
    weatherDesc: '获取中...',
    weatherIcon: '⏳'
  };

  // ========== 加载状态 ==========
  @State isLoadingDevice: boolean = true;
  @State isLoadingWeather: boolean = true;

  // 设备数据HTTP请求对象（复用）
  private deviceHttpRequest: http.HttpRequest | null = null;
  // 设备数据定时器ID
  private deviceTimerId: number = -1;
  // 天气数据定时器ID
  private weatherTimerId: number = -1;

  // 轮播图数据
  private swiperData: SwiperItem[] = [
    {
      image: $rawfile('banner/banner_1.png'),
      title: '智能灌溉系统',
      desc: '自动调节土壤湿度'
    },
    {
      image: $rawfile('banner/banner_2.png'),
      title: '水稻生长监测',
      desc: '分蘖期 · 长势优良'
    },
    {
      image: $rawfile('banner/banner_3.png'),
      title: '农事建议',
      desc: '今日适宜施肥'
    },
    {
      image: $rawfile('banner/banner_4.png'),
      title: '农事建议',
      desc: '今日适宜施肥'
    }
  ];

  // ==================== 生命周期 ====================
  aboutToAppear(): void {
    console.log('========== 🏠 Home页面加载 ==========');

    // 设置加载状态
    this.isLoadingDevice = true;
    this.isLoadingWeather = true;

    // 创建设备数据HTTP请求对象（复用）
    this.deviceHttpRequest = http.createHttp();

    // 先获取一次设备数据
    this.fetchDeviceData();

    // 每3秒轮询设备数据
    this.deviceTimerId = setInterval(() => {
      this.fetchDeviceData();
    }, 3000);

    // 延迟500ms后获取天气数据，确保页面初始化完成
    setTimeout(() => {
      console.log('🌤️ 准备开始获取天气数据...');
      this.fetchWeatherData();
    }, 500);

    // 每30分钟更新一次天气（1800000毫秒）
    this.weatherTimerId = setInterval(() => {
      console.log('🌤️ 定时刷新天气...');
      this.fetchWeatherData();
    }, 1800000);

    console.log('✅ 数据请求已发起，等待返回...');
  }

  aboutToDisappear(): void {
    console.log('========== 🏠 Home页面卸载 ==========');

    // 清除设备数据定时器
    if (this.deviceTimerId !== -1) {
      clearInterval(this.deviceTimerId);
      this.deviceTimerId = -1;
      console.log('🧹 设备数据定时器已清除');
    }

    // 清除天气数据定时器
    if (this.weatherTimerId !== -1) {
      clearInterval(this.weatherTimerId);
      this.weatherTimerId = -1;
      console.log('🧹 天气数据定时器已清除');
    }

    // 销毁设备数据HTTP请求对象
    if (this.deviceHttpRequest) {
      this.deviceHttpRequest.destroy();
      this.deviceHttpRequest = null;
      console.log('🧹 设备数据HTTP请求对象已销毁');
    }
  }

  // ==================== 设备数据 ====================
  async fetchDeviceData() {
    if (!this.deviceHttpRequest) {
      console.warn('⚠️ deviceHttpRequest 未初始化');
      return;
    }

    try {
      console.log('📤 请求设备数据: http://192.168.99.46:8080/api/data/latest');

      const responseData = await this.deviceHttpRequest.request(
        "http://192.168.99.46:8080/api/data/latest",
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          },
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 10000,
          readTimeout: 10000
        }
      )

      console.log('📥 设备数据返回: ' + responseData.result.toString())

      const DevJSON: DevData = JSON.parse(responseData.result.toString())

      if (DevJSON.code === 200) {
        this.temperature = DevJSON.data.temperature
        this.humidity = DevJSON.data.humidity
        this.lightIntensity = DevJSON.data.luminance
        this.updateTime = DevJSON.data.times
        this.isOnline = true
        this.isLoadingDevice = false
        console.log(`✅ 设备数据更新: 温度:${this.temperature}℃ 湿度:${this.humidity}% 光照:${this.lightIntensity}Lux`)
      } else {
        this.isOnline = false
        this.isLoadingDevice = false
        console.warn('⚠️ 设备数据返回 code 非 200:', DevJSON.code)
      }
    } catch (error) {
      console.error('❌ 获取设备数据失败：' + error)
      this.isOnline = false
      this.isLoadingDevice = false
      this.updateTime = '获取失败'
    }
  }

  // ==================== 天气数据 ====================
  async fetchWeatherData() {
    console.log('🌤️ ===== fetchWeatherData() 开始执行 =====');

    // 对城市名进行URL编码，解决中文参数问题
    const cityName = '呼和浩特';
    const encodedCity = encodeURIComponent(cityName);
    const url = `http://192.168.99.46:8080/api/weather/now?city=${encodedCity}`;

    console.log('🌤️ 原始城市名: ' + cityName);
    console.log('🌤️ 编码后城市名: ' + encodedCity);
    console.log('🌤️ 完整请求URL: ' + url);

    // 每次创建新的 HTTP 请求对象
    let httpRequest: http.HttpRequest | null = null;

    try {
      httpRequest = http.createHttp();
      console.log('🌤️ HTTP 请求对象创建成功');

      console.log('🌤️ 正在发送请求...');
      const responseData = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          },
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 15000,
          readTimeout: 15000
        }
      )

      const responseStr = responseData.result.toString();
      console.log('📥 天气数据返回长度: ' + responseStr.length);
      console.log('📥 天气数据返回: ' + responseStr);

      const weatherJSON: WeatherApiResponse = JSON.parse(responseStr)
      console.log('📥 JSON解析成功, code=' + weatherJSON.code);

      if (weatherJSON.code === 200) {
        const data = weatherJSON.data
        const weatherIcon = this.getWeatherIcon(data.text)

        this.weatherData = {
          city: data.city,
          outdoorTemp: parseFloat(data.temp),
          feelsLike: parseFloat(data.feelsLike),
          outdoorHumidity: parseFloat(data.humidity),
          windDir: data.windDir,
          windScale: data.windScale + '级',
          weatherDesc: data.text,
          weatherIcon: weatherIcon
        }

        this.isLoadingWeather = false
        console.log(`✅ 天气更新成功: ${data.city} ${data.text} 温度:${data.temp}℃ 湿度:${data.humidity}%`)
      } else {
        console.warn('⚠️ 天气数据返回 code 非 200:', weatherJSON.code)
        this.isLoadingWeather = false
        this.weatherData = {
          city: '获取失败',
          outdoorTemp: 0,
          feelsLike: 0,
          outdoorHumidity: 0,
          windDir: '--',
          windScale: '--',
          weatherDesc: '数据异常',
          weatherIcon: '⚠️'
        }
      }
    } catch (error) {
      console.error('❌ 获取天气数据异常!')
      console.error('❌ 错误类型: ' + typeof error)
      console.error('❌ 错误内容: ' + JSON.stringify(error))

      if (error instanceof Error) {
        console.error('❌ 错误消息: ' + error.message)
        console.error('❌ 错误堆栈: ' + error.stack)
      }

      this.isLoadingWeather = false
      this.weatherData = {
        city: '网络错误',
        outdoorTemp: 0,
        feelsLike: 0,
        outdoorHumidity: 0,
        windDir: '--',
        windScale: '--',
        weatherDesc: '请检查网络',
        weatherIcon: '⚠️'
      }
    } finally {
      // 确保每次请求后销毁HTTP对象
      if (httpRequest) {
        httpRequest.destroy();
        console.log('🌤️ HTTP请求对象已销毁');
      }
    }

    console.log('🌤️ ===== fetchWeatherData() 执行结束 =====');
  }

  // ==================== 工具方法 ====================
  getWeatherIcon(weatherText: string): string {
    if (weatherText.includes('晴')) {
      return '☀️'
    } else if (weatherText.includes('多云')) {
      return '⛅'
    } else if (weatherText.includes('阴')) {
      return '☁️'
    } else if (weatherText.includes('小雨') || weatherText.includes('阵雨')) {
      return '🌧️'
    } else if (weatherText.includes('中雨')) {
      return '🌧️'
    } else if (weatherText.includes('大雨') || weatherText.includes('暴雨')) {
      return '⛈️'
    } else if (weatherText.includes('雷')) {
      return '⚡'
    } else if (weatherText.includes('雪')) {
      return '❄️'
    } else if (weatherText.includes('雾') || weatherText.includes('霾')) {
      return '🌫️'
    } else if (weatherText.includes('风')) {
      return '💨'
    } else {
      return '🌤️'
    }
  }

  // ==================== UI 构建 ====================
  build() {
    Stack() {
      // ==================== 背景层 ====================
      Image($r('app.media.bg_home'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .position({ x: 0, y: 0 })

      // 半透明遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.15)')
        .position({ x: 0, y: 0 })

      // ==================== 内容层 ====================
      Column() {
        // 顶部标题栏
        Row() {
          Text('🌾 智慧农业')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .shadow({ radius: 4, color: '#00000020', offsetX: 0, offsetY: 2 })

          Blank()

          Row() {
            Text('●')
              .fontSize(12)
              .fontColor(this.isOnline ? '#4caf50' : '#ff5252')
              .margin({ right: 4 })
            Text(this.isOnline ? '在线' : '离线')
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
          .backgroundColor('#FFFFFF30')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(20)
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16 })

        // 滚动内容区域
        Scroll() {
          Column() {
            // ========== 上方环境数据 ==========
            Row() {
              // 温度卡片
              Column() {
                if (this.isLoadingDevice) {
                  LoadingProgress()
                    .width(28)
                    .height(28)
                    .color('#FFFFFF')
                    .margin({ bottom: 12 })
                } else {
                  Text('🌡️')
                    .fontSize(28)
                    .margin({ bottom: 12 })
                }
                Text(this.temperature.toFixed(1))
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .fontFamily('sans-serif-medium')
                Text('°C')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .opacity(0.8)
                  .margin({ top: 2 })
                Text('温度')
                  .fontSize(11)
                  .fontColor('#FFFFFF')
                  .opacity(0.9)
                  .margin({ top: 10 })
                  .padding({ left: 12, right: 12, top: 3, bottom: 3 })
                  .backgroundColor('#FFFFFF25')
                  .borderRadius(10)
              }
              .width('31%')
              .aspectRatio(0.85)
              .borderRadius(18)
              .justifyContent(FlexAlign.Center)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['#FF6B6B', 0], ['#FF8E8E', 1]]
              })
              .shadow({ radius: 12, color: '#FF6B6B50', offsetX: 0, offsetY: 6 })

              // 湿度卡片
              Column() {
                if (this.isLoadingDevice) {
                  LoadingProgress()
                    .width(28)
                    .height(28)
                    .color('#FFFFFF')
                    .margin({ bottom: 12 })
                } else {
                  Text('💧')
                    .fontSize(28)
                    .margin({ bottom: 12 })
                }
                Text(this.humidity.toFixed(1))
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .fontFamily('sans-serif-medium')
                Text('%')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .opacity(0.8)
                  .margin({ top: 2 })
                Text('湿度')
                  .fontSize(11)
                  .fontColor('#FFFFFF')
                  .opacity(0.9)
                  .margin({ top: 10 })
                  .padding({ left: 12, right: 12, top: 3, bottom: 3 })
                  .backgroundColor('#FFFFFF25')
                  .borderRadius(10)
              }
              .width('31%')
              .aspectRatio(0.85)
              .borderRadius(18)
              .justifyContent(FlexAlign.Center)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['#4ECDC4', 0], ['#6EE7DE', 1]]
              })
              .shadow({ radius: 12, color: '#4ECDC450', offsetX: 0, offsetY: 6 })

              // 光照强度卡片
              Column() {
                if (this.isLoadingDevice) {
                  LoadingProgress()
                    .width(28)
                    .height(28)
                    .color('#FFFFFF')
                    .margin({ bottom: 12 })
                } else {
                  Text('☀️')
                    .fontSize(28)
                    .margin({ bottom: 12 })
                }
                Text(this.lightIntensity.toFixed(1))
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .fontFamily('sans-serif-medium')
                Text('Lux')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .opacity(0.8)
                  .margin({ top: 2 })
                Text('光照强度')
                  .fontSize(11)
                  .fontColor('#FFFFFF')
                  .opacity(0.9)
                  .margin({ top: 10 })
                  .padding({ left: 12, right: 12, top: 3, bottom: 3 })
                  .backgroundColor('#FFFFFF25')
                  .borderRadius(10)
              }
              .width('31%')
              .aspectRatio(0.85)
              .borderRadius(18)
              .justifyContent(FlexAlign.Center)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['#FFB347', 0], ['#FFCC5C', 1]]
              })
              .shadow({ radius: 12, color: '#FFB34750', offsetX: 0, offsetY: 6 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 16 })

            // 数据更新时间
            Text(this.updateTime ? `大棚数据更新: ${this.updateTime}` : '正在获取数据...')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.8)
              .margin({ top: 8 })

            // ========== 轮播图 ==========
            Column() {
              Swiper() {
                ForEach(this.swiperData, (item: SwiperItem, index: number) => {
                  Stack() {
                    Image(item.image)
                      .width('100%')
                      .height('100%')
                      .objectFit(ImageFit.Cover)
                      .borderRadius(18)
                    Column()
                      .width('100%')
                      .height('100%')
                      .borderRadius(18)
                      .linearGradient({
                        direction: GradientDirection.Top,
                        colors: [['#00000000', 0], ['#00000040', 0.5], ['#00000090', 1]]
                      })
                    Column() {
                      Text(item.title)
                        .fontSize(20)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                        .shadow({ radius: 4, color: '#00000050', offsetX: 0, offsetY: 2 })
                      Text(item.desc)
                        .fontSize(13)
                        .fontColor('#FFFFFF')
                        .opacity(0.9)
                        .margin({ top: 6 })
                        .shadow({ radius: 3, color: '#00000040', offsetX: 0, offsetY: 1 })
                    }
                    .width('100%')
                    .position({ bottom: 28 })
                    .alignItems(HorizontalAlign.Start)
                    .padding({ left: 20 })
                  }
                  .width('100%')
                  .height('100%')
                })
              }
              .width('100%')
              .height(180)
              .autoPlay(true)
              .interval(3500)
              .indicator(
                new DotIndicator()
                  .color('#FFFFFF60')
                  .selectedColor('#FFFFFF')
                  .itemWidth(8)
                  .itemHeight(8)
                  .selectedItemWidth(22)
                  .selectedItemHeight(8)
              )
              .borderRadius(18)
              .margin({ top: 24 })
              .shadow({ radius: 16, color: '#00000020', offsetX: 0, offsetY: 6 })
              .onChange((index: number) => {
                this.currentBannerIndex = index;
              })
            }
            .width('100%')

            // ========== 和风天气 ==========
            Row() {
              Text('🌤️ 和风天气')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2E7D32')
              Blank()
              if (this.isLoadingWeather) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color('#4CAF50')
              } else {
                Text(this.weatherData.city)
                  .fontSize(14)
                  .fontColor('#4CAF50')
                  .backgroundColor('#E8F5E9')
                  .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                  .borderRadius(12)
              }
            }
            .width('100%')
            .margin({ top: 32, bottom: 16 })

            // ========== 天气网格 ==========
            Column() {
              Grid() {
                // 天气状况
                GridItem() {
                  Column() {
                    if (this.isLoadingWeather) {
                      LoadingProgress()
                        .width(36)
                        .height(36)
                        .color('#4CAF50')
                        .margin({ bottom: 8 })
                      Text('加载中...')
                        .fontSize(12)
                        .fontColor('#888888')
                    } else {
                      Text(this.weatherData.weatherIcon)
                        .fontSize(36)
                        .margin({ bottom: 8 })
                      Text(this.weatherData.weatherDesc)
                        .fontSize(17)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333333')
                      Text('天气状况')
                        .fontSize(11)
                        .fontColor('#888888')
                        .margin({ top: 6 })
                    }
                  }
                  .width('100%')
                  .aspectRatio(1.1)
                  .justifyContent(FlexAlign.Center)
                }
                // 室外温度
                GridItem() {
                  Column() {
                    if (this.isLoadingWeather) {
                      LoadingProgress()
                        .width(36)
                        .height(36)
                        .color('#4CAF50')
                        .margin({ bottom: 8 })
                    } else {
                      Text('🌡️')
                        .fontSize(36)
                        .margin({ bottom: 8 })
                    }
                    Text(this.weatherData.outdoorTemp.toString())
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FF6B6B')
                      .fontFamily('sans-serif-medium')
                    Text('°C')
                      .fontSize(10)
                      .fontColor('#888888')
                      .margin({ top: 2 })
                    Text('室外温度')
                      .fontSize(11)
                      .fontColor('#888888')
                      .margin({ top: 6 })
                  }
                  .width('100%')
                  .aspectRatio(1.1)
                  .justifyContent(FlexAlign.Center)
                }
                // 体感温度
                GridItem() {
                  Column() {
                    if (this.isLoadingWeather) {
                      LoadingProgress()
                        .width(36)
                        .height(36)
                        .color('#4CAF50')
                        .margin({ bottom: 8 })
                    } else {
                      Text('🌡️')
                        .fontSize(36)
                        .margin({ bottom: 8 })
                    }
                    Text(this.weatherData.feelsLike.toString())
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FF8C00')
                      .fontFamily('sans-serif-medium')
                    Text('°C')
                      .fontSize(10)
                      .fontColor('#888888')
                      .margin({ top: 2 })
                    Text('体感温度')
                      .fontSize(11)
                      .fontColor('#888888')
                      .margin({ top: 6 })
                  }
                  .width('100%')
                  .aspectRatio(1.1)
                  .justifyContent(FlexAlign.Center)
                }
                // 室外湿度
                GridItem() {
                  Column() {
                    if (this.isLoadingWeather) {
                      LoadingProgress()
                        .width(36)
                        .height(36)
                        .color('#4CAF50')
                        .margin({ bottom: 8 })
                    } else {
                      Text('💧')
                        .fontSize(36)
                        .margin({ bottom: 8 })
                    }
                    Text(this.weatherData.outdoorHumidity.toString())
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#4ECDC4')
                      .fontFamily('sans-serif-medium')
                    Text('%')
                      .fontSize(10)
                      .fontColor('#888888')
                      .margin({ top: 2 })
                    Text('室外湿度')
                      .fontSize(11)
                      .fontColor('#888888')
                      .margin({ top: 6 })
                  }
                  .width('100%')
                  .aspectRatio(1.1)
                  .justifyContent(FlexAlign.Center)
                }
                // 风向
                GridItem() {
                  Column() {
                    if (this.isLoadingWeather) {
                      LoadingProgress()
                        .width(36)
                        .height(36)
                        .color('#4CAF50')
                        .margin({ bottom: 8 })
                    } else {
                      Text('🧭')
                        .fontSize(36)
                        .margin({ bottom: 8 })
                    }
                    Text(this.weatherData.windDir)
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')
                    Text('风向')
                      .fontSize(11)
                      .fontColor('#888888')
                      .margin({ top: 6 })
                  }
                  .width('100%')
                  .aspectRatio(1.1)
                  .justifyContent(FlexAlign.Center)
                }
                // 风力等级
                GridItem() {
                  Column() {
                    if (this.isLoadingWeather) {
                      LoadingProgress()
                        .width(36)
                        .height(36)
                        .color('#4CAF50')
                        .margin({ bottom: 8 })
                    } else {
                      Text('💨')
                        .fontSize(36)
                        .margin({ bottom: 8 })
                    }
                    Text(this.weatherData.windScale)
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')
                    Text('风力等级')
                      .fontSize(11)
                      .fontColor('#888888')
                      .margin({ top: 6 })
                  }
                  .width('100%')
                  .aspectRatio(1.1)
                  .justifyContent(FlexAlign.Center)
                }
              }
              .columnsTemplate('1fr 1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .width('100%')
            }
            .width('100%')
            .padding(14)
            .backgroundColor('#FFFFFFCC')
            .borderRadius(20)
            .shadow({ radius: 16, color: '#00000010', offsetX: 0, offsetY: 4 })
            .backdropBlur(20)

            // ========== 底部留白 ==========
            Column()
              .width('100%')
              .height(120)
          }
          .padding({
            left: 16,
            right: 16,
            bottom: 30,
            top: 0
          })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

      // ========== 悬浮球 ==========
      FloatingBall()
    }
    .width('100%')
    .height('100%')
  }
}