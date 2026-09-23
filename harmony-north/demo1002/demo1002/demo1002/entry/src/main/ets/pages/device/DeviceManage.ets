// pages/device/DeviceManage.ets
import { promptAction, AppStorageV2 } from '@kit.ArkUI';

// 设备信息接口
interface DeviceInfo {
  id: string;
  name: string;
  type: 'pump' | 'light' | 'buzzer';
  status: boolean;
  icon: string;
  desc: string;
}

interface GeneratedTypeLiteralInterface_1 {
  name: string;
  icon: string;
  desc: string;
}

@Component
export struct DeviceManage {
  // 获取路由栈
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!

  // 设备列表
  @State deviceList: DeviceInfo[] = [
    {
      id: 'device_001',
      name: '水泵',
      type: 'pump',
      status: false,
      icon: '💧',
      desc: '智能灌溉水泵'
    },
    {
      id: 'device_002',
      name: '补光灯',
      type: 'light',
      status: true,
      icon: '💡',
      desc: 'LED植物补光灯'
    },
    {
      id: 'device_003',
      name: '蜂鸣器',
      type: 'buzzer',
      status: false,
      icon: '🔔',
      desc: '异常报警蜂鸣器'
    }
  ];

  // 是否显示添加设备弹窗
  @State showAddDialog: boolean = false;
  // 新设备类型
  @State newDeviceType: string = '';

  aboutToAppear() {
    console.log('📱 设备管理页面加载');
    console.log('当前设备数量:', this.deviceList.length);
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
            colors: [['#E8F5E9', 0], ['#F1F8E9', 0.3], ['#FAFAFA', 1]]
          })

        // ==================== 内容层 ====================
        Column() {
          // 顶部标题栏
          Row() {
            // 返回按钮
            Row() {
              Text('←')
                .fontSize(24)
                .fontColor('#4CAF50')
                .fontWeight(FontWeight.Bold)
              Text('返回')
                .fontSize(16)
                .fontColor('#4CAF50')
                .margin({ left: 4 })
            }
            .onClick(() => {
              this.pageStack.pop();
            })

            Blank()

            Text('📱 我的设备')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Blank()

            // 设备数量
            Text(`${this.deviceList.length}个设备`)
              .fontSize(14)
              .fontColor('#999999')
              .backgroundColor('#F5F5F5')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(12)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 4, color: '#00000010', offsetX: 0, offsetY: 2 })

          // 滚动内容区域
          Scroll() {
            Column() {
              // ==================== 添加设备按钮 ====================
              Row() {
                Text('➕')
                  .fontSize(28)
                Text('添加新设备')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#4CAF50')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .border({ width: 2, color: '#4CAF50', style: BorderStyle.Dashed })
              .margin({ top: 16, bottom: 8 })
              .onClick(() => {
                this.showAddDialog = true;
              })

              // ==================== 设备列表 ====================
              ForEach(this.deviceList, (item: DeviceInfo, index: number) => {
                this.DeviceCard(item, index)
              }, (item: DeviceInfo) => item.id)

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

        // ==================== 添加设备弹窗 ====================
        if (this.showAddDialog) {
          this.AddDeviceDialog()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }

  // ========== 设备卡片 ==========
  @Builder
  DeviceCard(item: DeviceInfo, index: number) {
    Row() {
      // 设备图标
      Column() {
        Text(item.icon)
          .fontSize(40)
      }
      .width(70)
      .height(70)
      .borderRadius(20)
      .backgroundColor(this.getDeviceColor(item.type) + '20')
      .justifyContent(FlexAlign.Center)

      // 设备信息
      Column() {
        Row() {
          Text(item.name)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          // 设备状态标签
          Text(item.status ? '运行中' : '已停止')
            .fontSize(11)
            .fontColor(item.status ? '#4CAF50' : '#999999')
            .backgroundColor(item.status ? '#E8F5E9' : '#F5F5F5')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ left: 8 })
        }
        .margin({ bottom: 6 })

        Row() {
          Text(item.desc)
            .fontSize(13)
            .fontColor('#999999')

          Blank()

          Text(`ID: ${item.id}`)
            .fontSize(11)
            .fontColor('#CCCCCC')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .margin({ left: 14 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 12 })
    .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 })
    .onClick(() => {
      this.handleDeviceClick(item);
    })
  }

  // ========== 添加设备弹窗 ==========
  @Builder
  AddDeviceDialog() {
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
          Text('添加新设备')
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

        // 设备类型选择
        Text('选择设备类型')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 12 })

        Row() {
          // 水泵
          Column() {
            Text('💧')
              .fontSize(36)
              .margin({ bottom: 8 })
            Text('水泵')
              .fontSize(14)
              .fontColor(this.newDeviceType === 'pump' ? '#FFFFFF' : '#333333')
          }
          .width('30%')
          .aspectRatio(1)
          .borderRadius(14)
          .backgroundColor(this.newDeviceType === 'pump' ? '#2196F3' : '#F5F5F5')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.newDeviceType = 'pump';
          })

          // 补光灯
          Column() {
            Text('💡')
              .fontSize(36)
              .margin({ bottom: 8 })
            Text('补光灯')
              .fontSize(14)
              .fontColor(this.newDeviceType === 'light' ? '#FFFFFF' : '#333333')
          }
          .width('30%')
          .aspectRatio(1)
          .borderRadius(14)
          .backgroundColor(this.newDeviceType === 'light' ? '#FF9800' : '#F5F5F5')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.newDeviceType = 'light';
          })

          // 蜂鸣器
          Column() {
            Text('🔔')
              .fontSize(36)
              .margin({ bottom: 8 })
            Text('蜂鸣器')
              .fontSize(14)
              .fontColor(this.newDeviceType === 'buzzer' ? '#FFFFFF' : '#333333')
          }
          .width('30%')
          .aspectRatio(1)
          .borderRadius(14)
          .backgroundColor(this.newDeviceType === 'buzzer' ? '#9C27B0' : '#F5F5F5')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.newDeviceType = 'buzzer';
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
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
              this.newDeviceType = '';
            })

          Button('确认添加')
            .width('45%')
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(22)
            .shadow({ radius: 8, color: '#4CAF5040', offsetX: 0, offsetY: 4 })
            .onClick(() => {
              this.confirmAddDevice();
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

  // ========== 工具方法 ==========
  getDeviceColor(type: string): string {
    switch (type) {
      case 'pump':
        return '#2196F3';
      case 'light':
        return '#FF9800';
      case 'buzzer':
        return '#9C27B0';
      default:
        return '#4CAF50';
    }
  }

  handleDeviceClick(device: DeviceInfo) {
    console.log('点击设备:', device.name);
    promptAction.showToast({
      message: `设备: ${device.name} - ${device.status ? '运行中' : '已停止'}`,
      duration: 1500
    });
  }

  confirmAddDevice() {
    if (!this.newDeviceType) {
      promptAction.showToast({
        message: '请选择设备类型',
        duration: 1500
      });
      return;
    }

    const typeMap: Record<string, GeneratedTypeLiteralInterface_1> = {
      'pump': { name: '水泵', icon: '💧', desc: '智能灌溉水泵' },
      'light': { name: '补光灯', icon: '💡', desc: 'LED植物补光灯' },
      'buzzer': { name: '蜂鸣器', icon: '🔔', desc: '异常报警蜂鸣器' }
    };

    const typeInfo = typeMap[this.newDeviceType];
    const newDevice: DeviceInfo = {
      id: `device_${Date.now()}`,
      name: typeInfo.name,
      type: this.newDeviceType as 'pump' | 'light' | 'buzzer',
      status: false,
      icon: typeInfo.icon,
      desc: typeInfo.desc
    };

    this.deviceList = [...this.deviceList, newDevice];
    this.showAddDialog = false;
    this.newDeviceType = '';

    promptAction.showToast({
      message: `添加${typeInfo.name}成功`,
      duration: 1500
    });

    console.log('✅ 新设备已添加:', JSON.stringify(newDevice));
    console.log('当前设备总数:', this.deviceList.length);
  }
}

// ========== Builder 导出函数（必须添加）==========
@Builder
export function DeviceManagePageBuilder() {
  DeviceManage()
}