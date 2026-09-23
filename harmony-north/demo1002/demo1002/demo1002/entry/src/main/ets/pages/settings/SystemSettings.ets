// pages/settings/SystemSettings.ets
import { AppStorageV2, promptAction } from '@kit.ArkUI';

// 设置项接口
interface SettingItem {
  id: string;
  icon: string;
  title: string;
  desc: string;
  color: string;
  type: 'switch' | 'navigate' | 'info';
  value?: boolean;
  route?: string;
}

@Component
export struct SystemSettings {
  // 获取路由栈
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!

  // 通知开关
  @State notificationEnabled: boolean = true;
  // 声音开关
  @State soundEnabled: boolean = true;
  // 振动开关
  @State vibrationEnabled: boolean = false;
  // 自动更新
  @State autoUpdate: boolean = true;
  // 数据同步
  @State dataSync: boolean = true;

  // 设置列表
  @State settingsList: SettingItem[][] = [
    // 第一组：通知设置
    [
      {
        id: 'notification',
        icon: '🔔',
        title: '消息通知',
        desc: '接收设备告警和系统通知',
        color: '#FF9800',
        type: 'switch',
        value: true
      },
      {
        id: 'sound',
        icon: '🔊',
        title: '声音提醒',
        desc: '设备异常时发出声音警报',
        color: '#2196F3',
        type: 'switch',
        value: true
      },
      {
        id: 'vibration',
        icon: '📳',
        title: '振动提醒',
        desc: '接收消息时手机振动',
        color: '#9C27B0',
        type: 'switch',
        value: false
      }
    ],
    // 第二组：系统设置
    [
      {
        id: 'autoUpdate',
        icon: '🔄',
        title: '自动更新',
        desc: '自动获取最新设备数据',
        color: '#4CAF50',
        type: 'switch',
        value: true
      },
      {
        id: 'dataSync',
        icon: '☁️',
        title: '数据同步',
        desc: '同步数据到云端存储',
        color: '#00BCD4',
        type: 'switch',
        value: true
      },
      {
        id: 'cache',
        icon: '🗑️',
        title: '清除缓存',
        desc: '当前缓存 128MB',
        color: '#FF5252',
        type: 'info'
      }
    ],
    // 第三组：账户与安全
    [
      {
        id: 'account',
        icon: '👤',
        title: '账户信息',
        desc: '查看和编辑个人资料',
        color: '#4CAF50',
        type: 'navigate',
        route: 'AccountPage'
      },
      {
        id: 'password',
        icon: '🔒',
        title: '修改密码',
        desc: '定期更换密码保护账户安全',
        color: '#FF9800',
        type: 'navigate',
        route: 'PasswordPage'
      },
      {
        id: 'privacy',
        icon: '🛡️',
        title: '隐私设置',
        desc: '管理数据收集和隐私权限',
        color: '#2196F3',
        type: 'navigate',
        route: 'PrivacyPage'
      }
    ],
    // 第四组：关于
    [
      {
        id: 'about',
        icon: 'ℹ️',
        title: '关于应用',
        desc: '版本 1.0.0',
        color: '#607D8B',
        type: 'navigate',
        route: 'AboutPage'
      },
      {
        id: 'help',
        icon: '❓',
        title: '帮助中心',
        desc: '查看使用教程和常见问题',
        color: '#795548',
        type: 'navigate',
        route: 'HelpPage'
      },
      {
        id: 'feedback',
        icon: '💬',
        title: '意见反馈',
        desc: '告诉我们你的想法和建议',
        color: '#E91E63',
        type: 'navigate',
        route: 'FeedbackPage'
      }
    ]
  ];

  // 分组标题
  @State groupTitles: string[] = [
    '📳 通知设置',
    '⚙️ 系统设置',
    '🔐 账户与安全',
    '📋 其他'
  ];

  aboutToAppear() {
    console.log('⚙️ 系统设置页面加载');
  }

  build() {
    NavDestination() {
      Stack() {
        // ==================== 背景层 ====================
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#F5F5F5')

        // ==================== 内容层 ====================
        Column() {
          // 顶部标题栏
          Row() {
            // 返回按钮
            Row() {
              Text('←')
                .fontSize(24)
                .fontColor('#607D8B')
                .fontWeight(FontWeight.Bold)
              Text('返回')
                .fontSize(16)
                .fontColor('#607D8B')
                .margin({ left: 4 })
            }
            .onClick(() => {
              this.pageStack.pop();
            })

            Blank()

            Text('⚙️ 系统设置')
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
              // ==================== 用户信息卡片 ====================
              Row() {
                Column() {
                  Text('👤')
                    .fontSize(40)
                }
                .width(60)
                .height(60)
                .borderRadius(30)
                .backgroundColor('#E8EAF6')
                .justifyContent(FlexAlign.Center)

                Column() {
                  Text('当前用户')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ bottom: 4 })
                  Text('已登录 · 管理员')
                    .fontSize(13)
                    .fontColor('#999999')
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 14 })
                .layoutWeight(1)

                Text('›')
                  .fontSize(22)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .margin({ top: 16, bottom: 8 })
              .shadow({ radius: 8, color: '#00000008', offsetX: 0, offsetY: 3 })

              // ==================== 设置列表 ====================
              ForEach(this.settingsList, (group: SettingItem[], groupIndex: number) => {
                Column() {
                  // 分组标题
                  Text(this.groupTitles[groupIndex])
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#999999')
                    .width('100%')
                    .padding({ left: 4, top: 16, bottom: 8 })

                  // 分组内容
                  Column() {
                    ForEach(group, (item: SettingItem, itemIndex: number) => {
                      this.SettingItemRow(item, groupIndex, itemIndex)
                    }, (item: SettingItem) => item.id)
                  }
                  .width('100%')
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .shadow({ radius: 4, color: '#00000005', offsetX: 0, offsetY: 2 })
                }
                .width('100%')
              }, (group: SettingItem[], index: number) => index.toString())

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

  // ========== 设置项行 ==========
  @Builder
  SettingItemRow(item: SettingItem, groupIndex: number, itemIndex: number) {
    Row() {
      // 左侧图标
      Column() {
        Text(item.icon)
          .fontSize(24)
      }
      .width(42)
      .height(42)
      .borderRadius(12)
      .backgroundColor(item.color + '20')
      .justifyContent(FlexAlign.Center)

      // 内容
      Column() {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Text(item.desc)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      // 右侧控件
      if (item.type === 'switch') {
        Toggle({ type: ToggleType.Switch, isOn: this.getSwitchValue(item.id) })
          .selectedColor('#4CAF50')
          .onChange((isOn: boolean) => {
            this.setSwitchValue(item.id, isOn);
          })
      } else if (item.type === 'navigate') {
        Row() {
          Text('›')
            .fontSize(22)
            .fontColor('#CCCCCC')
        }
      } else if (item.type === 'info') {
        Row() {
          Text(this.getInfoValue(item.id))
            .fontSize(13)
            .fontColor('#999999')
            .margin({ right: 4 })
          Text('›')
            .fontSize(22)
            .fontColor('#CCCCCC')
        }
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .border({ width: { bottom: itemIndex < this.settingsList[groupIndex].length - 1 ? 0.5 : 0 }, color: '#F0F0F0' })
    .onClick(() => {
      this.handleItemClick(item);
    })
  }

  // ========== 工具方法 ==========
  getSwitchValue(id: string): boolean {
    switch (id) {
      case 'notification':
        return this.notificationEnabled;
      case 'sound':
        return this.soundEnabled;
      case 'vibration':
        return this.vibrationEnabled;
      case 'autoUpdate':
        return this.autoUpdate;
      case 'dataSync':
        return this.dataSync;
      default:
        return false;
    }
  }

  setSwitchValue(id: string, value: boolean) {
    switch (id) {
      case 'notification':
        this.notificationEnabled = value;
        break;
      case 'sound':
        this.soundEnabled = value;
        break;
      case 'vibration':
        this.vibrationEnabled = value;
        break;
      case 'autoUpdate':
        this.autoUpdate = value;
        break;
      case 'dataSync':
        this.dataSync = value;
        break;
    }
    console.log(`设置项 ${id} 切换为: ${value}`);
  }

  getInfoValue(id: string): string {
    switch (id) {
      case 'cache':
        return '128MB';
      default:
        return '';
    }
  }

  handleItemClick(item: SettingItem) {
    if (item.type === 'navigate') {
      console.log('跳转到:', item.route);
      promptAction.showToast({
        message: `跳转到 ${item.title}`,
        duration: 1500
      });
    } else if (item.type === 'info') {
      if (item.id === 'cache') {
        // 清除缓存
        promptAction.showDialog({
          title: '清除缓存',
          message: '确定要清除所有缓存数据吗？',
          buttons: [
            {
              text: '取消',
              color: '#999999'
            },
            {
              text: '确定',
              color: '#FF5252'
            }
          ]
        });
      }
    }
  }
}

// ========== Builder 导出函数 ==========
@Builder
export function SystemSettingsPageBuilder() {
  SystemSettings()
}