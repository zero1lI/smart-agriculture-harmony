// pages/data/DataStatistics.ets
import { AppStorageV2 } from '@kit.ArkUI';

// 统计数据接口
interface StatisticsData {
  title: string;
  value: string;
  unit: string;
  icon: string;
  color: string;
  trend: string;
}

interface ChartData {
  label: string;
  value: number;
}

@Component
export struct DataStatistics {
  // 获取路由栈
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!

  // 选择的时间范围
  @State selectedPeriod: string = 'day';

  // 统计数据
  @State statisticsList: StatisticsData[] = [
    {
      title: '平均温度',
      value: '28.5',
      unit: '°C',
      icon: '🌡️',
      color: '#FF6B6B',
      trend: '↑ 2.3%'
    },
    {
      title: '平均湿度',
      value: '65.2',
      unit: '%',
      icon: '💧',
      color: '#4ECDC4',
      trend: '↓ 1.5%'
    },
    {
      title: '累计光照',
      value: '12.8',
      unit: 'h',
      icon: '☀️',
      color: '#FFB347',
      trend: '↑ 5.1%'
    },
    {
      title: '灌溉次数',
      value: '6',
      unit: '次',
      icon: '🚿',
      color: '#2196F3',
      trend: '持平'
    }
  ];

  // 图表数据（温度变化）
  @State temperatureChart: ChartData[] = [
    { label: '00:00', value: 25 },
    { label: '04:00', value: 23 },
    { label: '08:00', value: 27 },
    { label: '12:00', value: 31 },
    { label: '16:00', value: 33 },
    { label: '20:00', value: 29 },
    { label: '24:00', value: 26 }
  ];

  // 图表数据（湿度变化）
  @State humidityChart: ChartData[] = [
    { label: '00:00', value: 70 },
    { label: '04:00', value: 75 },
    { label: '08:00', value: 68 },
    { label: '12:00', value: 55 },
    { label: '16:00', value: 50 },
    { label: '20:00', value: 62 },
    { label: '24:00', value: 68 }
  ];

  aboutToAppear() {
    console.log('📊 数据统计页面加载');
  }

  build() {
    NavDestination() {
      Stack() {
        // ==================== 背景层 ====================
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#E3F2FD', 0], ['#F3E5F5', 0.5], ['#FAFAFA', 1]]
          })

        // ==================== 内容层 ====================
        Column() {
          // 顶部标题栏
          Row() {
            // 返回按钮
            Row() {
              Text('←')
                .fontSize(24)
                .fontColor('#2196F3')
                .fontWeight(FontWeight.Bold)
              Text('返回')
                .fontSize(16)
                .fontColor('#2196F3')
                .margin({ left: 4 })
            }
            .onClick(() => {
              this.pageStack.pop();
            })

            Blank()

            Text('📊 数据统计')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Blank()

            // 占位
            Row()
              .width(60)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })

          // 滚动内容区域
          Scroll() {
            Column() {
              // ==================== 时间范围选择 ====================
              Row() {
                this.PeriodButton('day', '今日')
                this.PeriodButton('week', '本周')
                this.PeriodButton('month', '本月')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceEvenly)
              .margin({ top: 16, bottom: 8 })

              // ==================== 统计卡片 ====================
              Grid() {
                ForEach(this.statisticsList, (item: StatisticsData, index: number) => {
                  GridItem() {
                    this.StatisticsCard(item)
                  }
                })
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(12)
              .rowsGap(12)
              .width('100%')
              .margin({ top: 8 })

              // ==================== 温度变化图表 ====================
              Column() {
                Row() {
                  Text('🌡️ 温度变化趋势')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')

                  Blank()

                  Text('单位: °C')
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .width('100%')
                .margin({ bottom: 16 })

                // 柱状图
                Row() {
                  ForEach(this.temperatureChart, (item: ChartData) => {
                    Column() {
                      Text(item.value.toString())
                        .fontSize(11)
                        .fontColor('#FF6B6B')
                        .margin({ bottom: 4 })

                      Column()
                        .width(20)
                        .height(item.value * 3)
                        .borderRadius({ topLeft: 6, topRight: 6 })
                        .linearGradient({
                          direction: GradientDirection.Top,
                          colors: [['#FF6B6B', 0], ['#FF8E8E', 1]]
                        })

                      Text(item.label)
                        .fontSize(9)
                        .fontColor('#999999')
                        .margin({ top: 6 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.End)
                  })
                }
                .width('100%')
                .height(160)
                .alignItems(VerticalAlign.Bottom)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ top: 16 })
              .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 })

              // ==================== 湿度变化图表 ====================
              Column() {
                Row() {
                  Text('💧 湿度变化趋势')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')

                  Blank()

                  Text('单位: %')
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .width('100%')
                .margin({ bottom: 16 })

                // 折线图（用柱状图模拟）
                Row() {
                  ForEach(this.humidityChart, (item: ChartData) => {
                    Column() {
                      Text(item.value.toString())
                        .fontSize(11)
                        .fontColor('#4ECDC4')
                        .margin({ bottom: 4 })

                      Column()
                        .width(20)
                        .height(item.value * 1.5)
                        .borderRadius({ topLeft: 6, topRight: 6 })
                        .linearGradient({
                          direction: GradientDirection.Top,
                          colors: [['#4ECDC4', 0], ['#6EE7DE', 1]]
                        })

                      Text(item.label)
                        .fontSize(9)
                        .fontColor('#999999')
                        .margin({ top: 6 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.End)
                  })
                }
                .width('100%')
                .height(160)
                .alignItems(VerticalAlign.Bottom)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ top: 16 })
              .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 })

              // ==================== 数据汇总 ====================
              Column() {
                Text('📋 数据汇总')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .width('100%')
                  .margin({ bottom: 16 })

                this.SummaryRow('最高温度', '35.2°C', '14:30')
                this.SummaryRow('最低温度', '22.1°C', '04:15')
                this.SummaryRow('最高湿度', '85.3%', '06:00')
                this.SummaryRow('最低湿度', '45.6%', '15:45')
                this.SummaryRow('总灌溉量', '2.8L', '全天')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ top: 16 })
              .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 })

              // 底部留白
              Column()
                .width('100%')
                .height(80)
            }
            .padding({ left: 16, right: 16 })
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }

  // ========== 时间范围按钮 ==========
  @Builder
  PeriodButton(period: string, label: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedPeriod === period ? '#FFFFFF' : '#666666')
      .padding({ left: 20, right: 20, top: 8, bottom: 8 })
      .backgroundColor(this.selectedPeriod === period ? '#2196F3' : '#F5F5F5')
      .borderRadius(20)
      .onClick(() => {
        this.selectedPeriod = period;
        console.log('切换时间范围:', period);
      })
  }

  // ========== 统计卡片 ==========
  @Builder
  StatisticsCard(item: StatisticsData) {
    Column() {
      Text(item.icon)
        .fontSize(36)
        .margin({ bottom: 12 })

      Text(item.value)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.color)
        .fontFamily('sans-serif-medium')

      Row() {
        Text(item.unit)
          .fontSize(14)
          .fontColor('#999999')
      }
      .margin({ top: 4, bottom: 8 })

      Text(item.title)
        .fontSize(13)
        .fontColor('#666666')
        .margin({ bottom: 6 })

      Text(item.trend)
        .fontSize(12)
        .fontColor(item.trend.includes('↑') ? '#FF5252' :
          item.trend.includes('↓') ? '#4CAF50' : '#999999')
        .backgroundColor(item.trend.includes('↑') ? '#FFE8E8' :
          item.trend.includes('↓') ? '#E8F5E9' : '#F5F5F5')
        .padding({ left: 10, right: 10, top: 3, bottom: 3 })
        .borderRadius(10)
    }
    .width('100%')
    .aspectRatio(1)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 })
  }

  // ========== 汇总行 ==========
  @Builder
  SummaryRow(label: string, value: string, time: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .layoutWeight(1)

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ right: 12 })

      Text(time)
        .fontSize(12)
        .fontColor('#999999')
        .backgroundColor('#F5F5F5')
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .borderRadius(8)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .border({ width: { bottom: 0.5 }, color: '#F0F0F0' })
  }
}

// ========== Builder 导出函数 ==========
@Builder
export function DataStatisticsPageBuilder() {
  DataStatistics()
}