// Mine.ets
import promptAction from '@ohos.promptAction';
import { AppStorageV2 } from "@kit.ArkUI"
import { preferences } from '@kit.ArkData';  // ✅ 导入数据存储


// 定义菜单项类型
interface MenuItem {
  icon: string;
  title: string;
  desc: string;
  onClick: () => void;
}

// 用户信息类型
interface UserType {
  user_id: number,
  username: string,
  password: string,
  phone: string,
  email: string,
  times: string
}

@Component
export struct Mine {
  // 获取路由栈
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!

  // ========== 关键：使用 @StorageLink + @Watch 监听变化 ==========
  @StorageLink('refreshMine') @Watch('onRefreshMine') refreshMine: string = '0';

  @State isLoggedIn: boolean = false

  // 用户状态
  @State userInfo: UserType = {
    user_id: 0,
    username: '',
    password: '',
    phone: '',
    email: '',
    times: ''
  };

  // 菜单列表
  @State menuList: MenuItem[] = [];

  aboutToAppear() {
    console.log('========== Mine页面加载 ==========');
    this.checkLoginStatus();
    this.initMenu();
  }

  // ========== 关键：refreshMine 变化时自动调用 ==========
  onRefreshMine() {
    console.log('🔄 refreshMine变化，重新检查登录状态, 值:', this.refreshMine);
    this.checkLoginStatus();
  }

  // ✅ 修改：从本地持久化存储读取登录状态
  private async checkLoginStatus() {
    try {
      // 先从本地存储读取
      const prefs = await preferences.getPreferences(getContext(), 'user_prefs');
      const isLoggedInStr = await prefs.get('isLoggedIn', 'false');
      console.log('📂 本地存储 - 登录状态:', isLoggedInStr);

      if (isLoggedInStr === 'true') {
        const userDataStr = await prefs.get('userInfo', '');
        console.log('📂 本地存储 - 用户数据:', userDataStr);

        if (userDataStr) {
          try {
            const userData = JSON.parse(userDataStr as string) as UserType;
            console.log("解析后用户数据:", JSON.stringify(userData));

            // ========== 整体赋值确保视图更新 ==========
            this.userInfo = {
              user_id: userData.user_id || 0,
              username: userData.username || '',
              password: userData.password || '',
              phone: userData.phone || '',
              email: userData.email || '',
              times: userData.times || ''
            };
            this.isLoggedIn = true;

            // ✅ 同步到AppStorage（内存中）
            AppStorage.setOrCreate('isLoggedIn', 'true');
            AppStorage.setOrCreate('userInfo', userDataStr as string);

            console.log('✅ 用户已登录:', this.userInfo.username);
          } catch (error) {
            console.error("解析用户数据失败:", error);
            this.isLoggedIn = false;
          }
        } else {
          console.log("本地存储中没有用户数据，尝试从AppStorage读取");
          this.checkFromAppStorage();
        }
      } else {
        console.log("用户未登录");
        this.isLoggedIn = false;
      }
    } catch (error) {
      console.error('读取本地存储失败:', error);
      // 降级：从AppStorage读取
      this.checkFromAppStorage();
    }
  }

  // ✅ 降级方案：从AppStorage读取
  private checkFromAppStorage() {
    const isLoggedInStr = AppStorage.get<string>("isLoggedIn");
    console.log('检查AppStorage登录状态, isLoggedIn:', isLoggedInStr);

    if (isLoggedInStr === 'true') {
      const userDataStr = AppStorage.get<string>("userInfo");
      console.log("AppStorage用户数据:", userDataStr);

      if (userDataStr) {
        try {
          const userData = JSON.parse(userDataStr) as UserType;
          console.log("解析后用户数据:", JSON.stringify(userData));

          this.userInfo = {
            user_id: userData.user_id || 0,
            username: userData.username || '',
            password: userData.password || '',
            phone: userData.phone || '',
            email: userData.email || '',
            times: userData.times || ''
          };
          this.isLoggedIn = true;
          console.log('✅ 用户已登录(来自AppStorage):', this.userInfo.username);
        } catch (error) {
          console.error("解析用户数据失败:", error);
          this.isLoggedIn = false;
        }
      } else {
        console.log("没有用户数据，重置状态");
        AppStorage.setOrCreate('isLoggedIn', 'false');
        this.isLoggedIn = false;
      }
    } else {
      console.log("用户未登录");
      this.isLoggedIn = false;
    }
  }

  // Mine.ets 中的 initMenu() 方法
  private initMenu() {

    const menuItems: MenuItem[] = [
      {
        icon: '📱',
        title: '我的设备',
        desc: '管理所有设备',
        onClick: () => {
          this.pageStack.pushPathByName('DeviceManagePage', null, false);
        }
      },
      {
        icon: '📈',
        title: '数据统计',
        desc: '查看历史数据',
        onClick: () => {
          this.pageStack.pushPathByName('DataStatisticsPage', null, false);
        }
      },
      {
        icon: '📋',
        title: '农事记录',
        desc: '查看农事日志',
        onClick: () => {
          this.pageStack.pushPathByName('FarmRecordPage', null, false);
        }
      },
      {
        icon: '⚙️',
        title: '系统设置',
        desc: '账户与偏好',
        onClick: () => {
          this.pageStack.pushPathByName('SystemSettingsPage', null, false);
        }
      }
    ];

    this.menuList = menuItems;
  }

  build() {
    Stack() {
      // ==================== 背景层 ====================
      Image($r('app.media.bg_mine'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 半透明遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.08)')

      // ==================== 内容层 ====================
      Column() {
        // 顶部标题栏
        Row() {
          Text('👤 我的')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .shadow({ radius: 4, color: '#00000020', offsetX: 0, offsetY: 2 })

          Blank()

          if (this.isLoggedIn) {
            Text('已登录')
              .fontSize(13)
              .fontColor('#FFFFFF')
              .backgroundColor('rgba(76, 175, 80, 0.5)')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .borderRadius(12)
              .backdropBlur(10)
          }
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 8 })

        // 滚动内容区域
        Scroll() {
          Column() {
            // ==================== 用户信息卡片 ====================
            this.UserInfoCard()

            // ==================== 功能菜单标题 ====================
            Row() {
              Text('📋 功能菜单')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2E7D32')

              Blank()

              Text(`${this.menuList.length} 项`)
                .fontSize(12)
                .fontColor('#999999')
                .backgroundColor('#F5F5F5')
                .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                .borderRadius(10)
            }
            .width('100%')
            .padding({ left: 4, right: 4 })
            .margin({ top: 16, bottom: 12 })

            // ==================== 菜单列表 ====================
            Column() {
              ForEach(this.menuList, (item: MenuItem, index: number) => {
                this.MenuItem(item, index)
              }, (item: MenuItem, index: number) => index.toString())
            }
            .width('100%')

            // ==================== 底部留白 ====================
            Column()
              .width('100%')
              .height(100)
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

  // ========== 用户信息卡片 ==========
  @Builder
  UserInfoCard() {
    Column() {
      if (!this.isLoggedIn) {
        // ==================== 未登录状态 ====================
        Column() {
          Column() {
            Text('👤')
              .fontSize(60)
          }
          .width(90)
          .height(90)
          .borderRadius(45)
          .backgroundColor('rgba(255, 255, 255, 0.3)')
          .border({ width: 3, color: 'rgba(255, 255, 255, 0.6)' })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .shadow({ radius: 10, color: '#00000015', offsetX: 0, offsetY: 4 })

          Text('未登录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 16, bottom: 6 })

          Text('登录后享受更多功能')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ bottom: 20 })

          Row() {
            Button('去登录')
              .width(130)
              .height(44)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor('#4CAF50')
              .borderRadius(22)
              .shadow({ radius: 8, color: '#4CAF5040', offsetX: 0, offsetY: 4 })
              .onClick(() => {
                this.navigateToLogin();
              })

            Button('去注册')
              .width(130)
              .height(44)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#4CAF50')
              .backgroundColor('rgba(255, 255, 255, 0.8)')
              .borderRadius(22)
              .border({ width: 1.5, color: '#4CAF50' })
              .margin({ left: 16 })
              .onClick(() => {
                this.navigateToRegister();
              })
          }
        }
        .width('100%')
        .padding({ top: 28, bottom: 28 })
        .alignItems(HorizontalAlign.Center)
      } else {
        // ==================== 已登录状态 ====================
        Row() {
          Column() {
            Text('👤')
              .fontSize(50)
          }
          .width(75)
          .height(75)
          .borderRadius(37)
          .backgroundColor('rgba(255, 255, 255, 0.3)')
          .border({ width: 3, color: 'rgba(255, 255, 255, 0.6)' })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 3 })

          Column() {
            Text(this.userInfo.username || '用户')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1b4a1b')
              .margin({ bottom: 6 })

            Row() {
              Text('📱')
                .fontSize(13)
                .margin({ right: 4 })
              Text(this.userInfo.phone || '未绑定手机')
                .fontSize(13)
                .fontColor('#666666')
            }
            .margin({ bottom: 4 })

            if (this.userInfo.email) {
              Row() {
                Text('📧')
                  .fontSize(13)
                  .margin({ right: 4 })
                Text(this.userInfo.email)
                  .fontSize(13)
                  .fontColor('#666666')
              }
            }
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
          .layoutWeight(1)

          Button() {
            Row() {
              Text('退出')
                .fontSize(13)
                .fontColor('#FF5252')
              Text('→')
                .fontSize(13)
                .fontColor('#FF5252')
                .margin({ left: 2 })
            }
          }
          .height(36)
          .fontSize(13)
          .backgroundColor('rgba(255, 82, 82, 0.1)')
          .borderRadius(18)
          .padding({ left: 14, right: 14 })
          .border({ width: 1, color: 'rgba(255, 82, 82, 0.3)' })
          .onClick(() => {
            this.handleLogout();
          })
        }
        .width('100%')
        .padding(16)
      }
    }
    .width('100%')
    .backgroundColor('rgba(255, 255, 255, 0.85)')
    .borderRadius(20)
    .shadow({ radius: 12, color: '#00000010', offsetX: 0, offsetY: 4 })
    .backdropBlur(20)
    .margin({ top: 8 })
  }

  @Builder
  MenuItem(item: MenuItem, index: number) {
    Row() {
      Column() {
        Text(item.icon)
          .fontSize(26)
      }
      .width(48)
      .height(48)
      .backgroundColor(this.getMenuItemColor(index) + '20')
      .borderRadius(14)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 14 })

      Column() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        Text(item.desc)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('›')
        .fontSize(22)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 16, right: 16 })
    .backgroundColor('rgba(255, 255, 255, 0.85)')
    .borderRadius(14)
    .margin({ bottom: 8 })
    .shadow({ radius: 4, color: '#00000008', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      item.onClick();
    })
  }

  getMenuItemColor(index: number): string {
    const colors = ['#4CAF50', '#2196F3', '#FF9800', '#9C27B0', '#F44336', '#00BCD4'];
    return colors[index % colors.length];
  }

  navigateToLogin() {
    this.pageStack.pushPathByName('LoginPage', null, false);
  }

  navigateToRegister() {
    this.pageStack.pushPathByName('RegisterPage', null, false);
  }

  // ✅ 修改：退出登录时清除本地持久化存储
  async handleLogout() {
    console.log('退出登录');

    // 清除本地状态
    this.userInfo = {
      user_id: 0,
      username: '',
      password: '',
      phone: '',
      email: '',
      times: ''
    };
    this.isLoggedIn = false;

    // ✅ 清除本地持久化存储
    try {
      const prefs = await preferences.getPreferences(getContext(), 'user_prefs');
      await prefs.put('isLoggedIn', 'false');
      await prefs.put('userInfo', '');
      await prefs.flush();
      console.log('✅ 本地登录状态已清除');
    } catch (error) {
      console.error('清除本地存储失败:', error);
    }

    // 清除AppStorage（内存中）
    AppStorage.setOrCreate('isLoggedIn', 'false');
    AppStorage.setOrCreate('userInfo', '');
    AppStorage.setOrCreate('refreshMine', new Date().getTime().toString());

    promptAction.showToast({
      message: '已退出登录',
      duration: 1500
    });
  }
}