// pages/record/FarmRecord.ets
import { AppStorageV2 } from '@kit.ArkUI';

// ========== 接口名改为 FarmRecordItem（避免与组件名冲突）==========
interface FarmRecordItem {
  id: string;
  date: string;
  time: string;
  type: string;
  title: string;
  desc: string;
  icon: string;
  color: string;
  status: 'completed' | 'pending' | 'cancelled';
}

interface GeneratedTypeLiteralInterface_1 {
  key: string;
  label: string;
}

interface GeneratedTypeLiteralInterface_2 {
  key: string;
  label: string;
}

@Component
export struct FarmRecord {
  // 获取路由栈
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!
  // 当前选中的标签
  @State selectedTab: string = 'all';
  // 是否显示添加记录弹窗
  @State showAddDialog: boolean = false;
  // 新记录数据
  @State newRecordType: string = '';
  @State newRecordTitle: string = '';
  @State newRecordDesc: string = '';
  // ========== 使用 FarmRecordItem 类型 ==========
  @State recordList: FarmRecordItem[] = [
    {
      id: 'record_001',
      date: '2026-07-21',
      time: '08:30',
      type: 'fertilize',
      title: '施肥作业',
      desc: '施用复合肥，每亩15kg，重点关注分蘖期营养需求',
      icon: '🌱',
      color: '#4CAF50',
      status: 'completed'
    },
    {
      id: 'record_002',
      date: '2026-07-21',
      time: '06:00',
      type: 'irrigate',
      title: '灌溉作业',
      desc: '自动灌溉系统运行2小时，土壤湿度达到65%',
      icon: '💧',
      color: '#2196F3',
      status: 'completed'
    },
    {
      id: 'record_003',
      date: '2026-07-20',
      time: '15:00',
      type: 'pesticide',
      title: '喷洒农药',
      desc: '防治稻飞虱，使用低毒农药，按1:500比例稀释',
      icon: '🧪',
      color: '#FF9800',
      status: 'completed'
    },
    {
      id: 'record_004',
      date: '2026-07-22',
      time: '09:00',
      type: 'weed',
      title: '除草作业',
      desc: '人工除草，重点清理田埂周边杂草',
      icon: '🌿',
      color: '#9C27B0',
      status: 'pending'
    },
    {
      id: 'record_005',
      date: '2026-07-19',
      time: '10:00',
      type: 'harvest',
      title: '收割计划',
      desc: '因天气原因，原定收割计划取消，另行通知',
      icon: '🌾',
      color: '#FF5722',
      status: 'cancelled'
    }
  ];
  // 标签列表
  @State tabs: GeneratedTypeLiteralInterface_1[] = [
    { key: 'all', label: '全部' },
    { key: 'fertilize', label: '施肥' },
    { key: 'irrigate', label: '灌溉' },
    { key: 'pesticide', label: '农药' },
    { key: 'weed', label: '除草' },
    { key: 'harvest', label: '收割' }
  ];

  aboutToAppear() {
    console.log('📋 农事记录页面加载');
    console.log('当前记录数量:', this.recordList.length);
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
            colors: [['#FFF3E0', 0], ['#F1F8E9', 0.3], ['#FAFAFA', 1]]
          })

        // ==================== 内容层 ====================
        Column() {
          // 顶部标题栏
          Row() {
            // 返回按钮
            Row() {
              Text('←')
                .fontSize(24)
                .fontColor('#FF9800')
                .fontWeight(FontWeight.Bold)
              Text('返回')
                .fontSize(16)
                .fontColor('#FF9800')
                .margin({ left: 4 })
            }
            .onClick(() => {
              this.pageStack.pop();
            })

            Blank()

            Text('📋 农事记录')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Blank()

            // 添加按钮
            Row() {
              Text('➕')
                .fontSize(18)
            }
            .width(36)
            .height(36)
            .borderRadius(18)
            .backgroundColor('#FFF3E0')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.showAddDialog = true;
            })
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .shadow({
            radius: 4,
            color: '#00000010',
            offsetX: 0,
            offsetY: 2
          })

          // 滚动内容区域
          Scroll() {
            Column() {
              // ==================== 统计概览 ====================
              Row() {
                this.StatCard('✅ 已完成', this.getStatusCount('completed'), '#4CAF50', '#E8F5E9')
                this.StatCard('⏳ 待处理', this.getStatusCount('pending'), '#FF9800', '#FFF3E0')
                this.StatCard('❌ 已取消', this.getStatusCount('cancelled'), '#FF5252', '#FFE8E8')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ top: 16, bottom: 8 })

              // ==================== 分类标签 ====================
              Scroll() {
                Row() {
                  ForEach(this.tabs, (tab: GeneratedTypeLiteralInterface_2) => {
                    Text(tab.label)
                      .fontSize(13)
                      .fontColor(this.selectedTab === tab.key ? '#FFFFFF' : '#666666')
                      .padding({
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 8
                      })
                      .backgroundColor(this.selectedTab === tab.key ? '#FF9800' : '#F5F5F5')
                      .borderRadius(18)
                      .margin({ right: 8 })
                      .onClick(() => {
                        this.selectedTab = tab.key;
                      })
                  })
                }
                .padding({ left: 4 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              .margin({ top: 12, bottom: 8 })

              // ==================== 记录列表 ====================
              Column() {
                ForEach(this.getFilteredRecords(), (item: FarmRecordItem, index: number) => {
                  this.RecordCard(item, index)
                }, (item: FarmRecordItem) => item.id)
              }
              .width('100%')

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

        // ==================== 添加记录弹窗 ====================
        if (this.showAddDialog) {
          this.AddRecordDialog()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }

  // ========== 统计卡片 ==========
  @Builder
  StatCard(label: string, count: number, color: string, bgColor: string) {
    Column() {
      Text(count.toString())
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .fontFamily('sans-serif-medium')
      Text(label)
        .fontSize(11)
        .fontColor('#666666')
        .margin({ top: 4 })
    }
    .width('30%')
    .aspectRatio(1.5)
    .backgroundColor(bgColor)
    .borderRadius(14)
    .justifyContent(FlexAlign.Center)
  }

  // ========== 记录卡片 ==========
  @Builder
  RecordCard(item: FarmRecordItem, index: number) {
    Column() {
      Row() {
        // 左侧图标
        Column() {
          Text(item.icon)
            .fontSize(36)
        }
        .width(60)
        .height(60)
        .borderRadius(16)
        .backgroundColor(item.color + '20')
        .justifyContent(FlexAlign.Center)

        // 内容区域
        Column() {
          Row() {
            Text(item.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Blank()

            // 状态标签
            Text(this.getStatusText(item.status))
              .fontSize(11)
              .fontColor(this.getStatusColor(item.status))
              .backgroundColor(this.getStatusBgColor(item.status))
              .padding({
                left: 8,
                right: 8,
                top: 3,
                bottom: 3
              })
              .borderRadius(8)
          }
          .width('100%')
          .margin({ bottom: 6 })

          Text(item.desc)
            .fontSize(13)
            .fontColor('#999999')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Row() {
            Text('📅')
              .fontSize(13)
              .margin({ right: 4 })
            Text(item.date)
              .fontSize(12)
              .fontColor('#999999')

            Text('🕐')
              .fontSize(13)
              .margin({ left: 12, right: 4 })
            Text(item.time)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .layoutWeight(1)
        .margin({ left: 14 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 12 })
    .shadow({
      radius: 8,
      color: '#00000008',
      offsetX: 0,
      offsetY: 3
    })
  }

  // ========== 添加记录弹窗 ==========
  @Builder
  AddRecordDialog() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showAddDialog = false;
        })

      // 弹窗内容
      Column() {
        // 标题
        Row() {
          Text('添加农事记录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Blank()

          Text('✕')
            .fontSize(22)
            .fontColor('#999999')
            .onClick(() => {
              this.showAddDialog = false;
            })
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 记录类型选择
        Text('选择记录类型')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 12 })

        Grid() {
          GridItem() {
            this.TypeButton('fertilize', '🌱', '施肥')
          }

          GridItem() {
            this.TypeButton('irrigate', '💧', '灌溉')
          }

          GridItem() {
            this.TypeButton('pesticide', '🧪', '农药')
          }

          GridItem() {
            this.TypeButton('weed', '🌿', '除草')
          }

          GridItem() {
            this.TypeButton('harvest', '🌾', '收割')
          }

          GridItem() {
            this.TypeButton('other', '📝', '其他')
          }
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .margin({ bottom: 24 })

        // 确认按钮
        Row() {
          Button('取消')
            .width('45%')
            .height(44)
            .fontSize(15)
            .fontColor('#999999')
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => {
              this.showAddDialog = false;
              this.newRecordType = '';
            })

          Button('确认添加')
            .width('45%')
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF9800')
            .borderRadius(22)
            .shadow({
              radius: 8,
              color: '#FF980040',
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => {
              this.confirmAddRecord();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 24, topRight: 24 })
      .position({ bottom: 0 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(999)
  }

  // ========== 类型按钮 ==========
  @Builder
  TypeButton(type: string, icon: string, label: string) {
    Column() {
      Text(icon)
        .fontSize(30)
        .margin({ bottom: 6 })
      Text(label)
        .fontSize(13)
        .fontColor(this.newRecordType === type ? '#FFFFFF' : '#333333')
    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(12)
    .backgroundColor(this.newRecordType === type ? '#FF9800' : '#F5F5F5')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.newRecordType = type;
    })
  }

  // ========== 工具方法 ==========
  getFilteredRecords(): FarmRecordItem[] {
    if (this.selectedTab === 'all') {
      return this.recordList;
    }
    return this.recordList.filter((item: FarmRecordItem) => item.type === this.selectedTab);
  }

  getStatusCount(status: string): number {
    return this.recordList.filter((item: FarmRecordItem) => item.status === status).length;
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'completed':
        return '已完成';
      case 'pending':
        return '待处理';
      case 'cancelled':
        return '已取消';
      default:
        return '未知';
    }
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'completed':
        return '#4CAF50';
      case 'pending':
        return '#FF9800';
      case 'cancelled':
        return '#FF5252';
      default:
        return '#999999';
    }
  }

  getStatusBgColor(status: string): string {
    switch (status) {
      case 'completed':
        return '#E8F5E9';
      case 'pending':
        return '#FFF3E0';
      case 'cancelled':
        return '#FFE8E8';
      default:
        return '#F5F5F5';
    }
  }

  confirmAddRecord() {
    if (!this.newRecordType) {
      return;
    }

    const typeMap: Record<string, Record<string, string>> = {
      'fertilize': { "title": '施肥作业', "icon": '🌱', "color": '#4CAF50' },
      'irrigate': { "title": '灌溉作业', "icon": '💧', "color": '#2196F3' },
      'pesticide': { "title": '喷洒农药', "icon": '🧪', "color": '#FF9800' },
      'weed': { "title": '除草作业', "icon": '🌿', "color": '#9C27B0' },
      'harvest': { "title": '收割作业', "icon": '🌾', "color": '#FF5722' },
      'other': { "title": '其他作业', "icon": '📝', "color": '#607D8B' }
    };

    const typeInfo = typeMap[this.newRecordType];
    const now = new Date();
    const dateStr = `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, '0')}-${now.getDate()
      .toString()
      .padStart(2, '0')}`;
    const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

    const newRecord: FarmRecordItem = {
      id: `record_${Date.now()}`,
      date: dateStr,
      time: timeStr,
      type: this.newRecordType,
      title: typeInfo['title'],
      desc: '新添加的农事记录',
      icon: typeInfo['icon'],
      color: typeInfo['color'],
      status: 'pending'
    };

    this.recordList = [newRecord, ...this.recordList];
    this.showAddDialog = false;
    this.newRecordType = '';

    console.log('✅ 新记录已添加:', JSON.stringify(newRecord));
    console.log('当前记录总数:', this.recordList.length);
  }
}

// ========== Builder 导出函数 ==========
@Builder
export function FarmRecordPageBuilder() {
  FarmRecord()
}