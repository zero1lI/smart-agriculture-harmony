// Login.ets - 修复版（添加本地存储）
import promptAction from '@ohos.promptAction';
import { AppStorageV2 } from "@kit.ArkUI"
import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';

interface UserType {
  user_id: number,
  username: string,
  password: string,
  phone: string,
  email: string,
  times: string
}

interface UserData {
  code: number,
  data: UserType,
  message: string
}

// ✅ 加上 export
@Component
export struct Login {
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!
  @State phone: string = '13256481234';
  @State password: string = '123456';
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.checkAutoLogin();
  }

  async checkAutoLogin() {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'user_prefs');
      const isLoggedIn = await prefs.get('isLoggedIn', 'false');

      if (isLoggedIn === 'true') {
        console.log('🔑 检测到已登录，自动跳转...');
        const userDataStr = await prefs.get('userInfo', '');
        AppStorage.setOrCreate('isLoggedIn', 'true');
        AppStorage.setOrCreate('userInfo', userDataStr);
        AppStorage.setOrCreate('refreshMine', new Date().getTime().toString());

        setTimeout(() => {
          // ✅ 清空栈并跳转到主页
          this.pageStack.clear();
          this.pageStack.pushPathByName('LayoutPage', null, false);
        }, 300);
      }
    } catch (error) {
      console.error('读取登录状态失败:', error);
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['#E8F5E9', 0],
              ['#C8E6C9', 0.5],
              ['#A5D6A7', 1]
            ]
          })

        Column() {
          Row() {
            Text('‹')
              .fontSize(36)
              .fontColor('#2E7D32')
              .fontWeight(FontWeight.Bold)
              .onClick(() => {
                this.pageStack.pop();
              })

            Blank()
          }
          .width('100%')
          .padding({ left: 8, right: 16, top: 8 })
          .margin({ bottom: 20 })

          Column() {
            Column() {
              Text('🌾')
                .fontSize(60)
                .margin({ bottom: 8 })
            }
            .width(100)
            .height(100)
            .borderRadius(50)
            .backgroundColor('rgba(255, 255, 255, 0.5)')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .shadow({ radius: 15, color: '#00000015', offsetX: 0, offsetY: 6 })
            .margin({ bottom: 16 })

            Text('智慧农业')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1B5E20')

            Text('欢迎回来')
              .fontSize(16)
              .fontColor('#4CAF50')
              .margin({ top: 8 })
          }
          .width('100%')
          .margin({ bottom: 50 })

          Column() {
            Row() {
              Text('📱')
                .fontSize(20)
                .margin({ right: 12 })
              TextInput({ placeholder: '请输入手机号', text: this.phone })
                .height(50)
                .fontSize(16)
                .backgroundColor('transparent')
                .type(InputType.PhoneNumber)
                .maxLength(11)
                .onChange((value: string) => {
                  this.phone = value;
                })
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F5F5F5')
            .borderRadius(14)
            .margin({ bottom: 16 })

            Row() {
              Text('🔒')
                .fontSize(20)
                .margin({ right: 12 })
              TextInput({ placeholder: '请输入密码', text: this.password })
                .height(50)
                .fontSize(16)
                .backgroundColor('transparent')
                .type(InputType.Password)
                .maxLength(18)
                .onChange((value: string) => {
                  this.password = value;
                })
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F5F5F5')
            .borderRadius(14)
            .margin({ bottom: 24 })

            Button() {
              if (this.isLoading) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color('#FFFFFF')
              } else {
                Text('登 录')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
            }
            .width('100%')
            .height(52)
            .backgroundColor(this.isLoading ? '#A5D6A7' : '#2E7D32')
            .borderRadius(14)
            .enabled(!this.isLoading)
            .shadow({ radius: 8, color: '#2E7D3240', offsetX: 0, offsetY: 4 })
            .onClick(() => {
              this.handleLogin();
            })

            Row() {
              Text('💡 测试账号：')
                .fontSize(12)
                .fontColor('#999999')
              Text(`${this.phone.substring(0, 3)}****${this.phone.substring(7)}`)
                .fontSize(12)
                .fontColor('#4CAF50')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 16 })

            Row() {
              Text('还没有账号？')
                .fontSize(14)
                .fontColor('#666666')
              Text('立即注册')
                .fontSize(14)
                .fontColor('#2E7D32')
                .fontWeight(FontWeight.Bold)
                .onClick(() => {
                  this.pageStack.pushPathByName('RegisterPage', null, false);
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 24 })
          }
          .width('100%')
          .padding(24)
          .backgroundColor('rgba(255, 255, 255, 0.85)')
          .borderRadius(20)
          .shadow({ radius: 15, color: '#00000010', offsetX: 0, offsetY: 6 })
          .backdropBlur(20)
        }
        .width('100%')
        .height('100%')
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .hideTitleBar(true)
  }

  async handleLogin() {
    console.log('========== 开始登录 ==========');

    if (!this.phone || this.phone.length !== 11) {
      promptAction.showToast({ message: '请输入正确的11位手机号', duration: 1500 });
      return;
    }
    if (!this.password || this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6位', duration: 1500 });
      return;
    }

    this.isLoading = true;

    try {
      const url = 'http://192.168.99.46:8080/api/user/login?phone=' + this.phone + '&password=' + this.password;
      console.log('请求URL:', url);

      let httpRequest = http.createHttp();

      const responseData = await httpRequest.request(
        url,
        {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' },
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 10000,
          readTimeout: 10000,
        }
      )

      console.log('登录响应:', responseData.result.toString());

      const UserJson: UserData = JSON.parse(responseData.result.toString());

      if (UserJson.code === 200) {
        console.log('✅ 登录成功');

        const userInfoStr = JSON.stringify(UserJson.data);
        AppStorage.setOrCreate('userInfo', userInfoStr);
        AppStorage.setOrCreate('isLoggedIn', 'true');
        AppStorage.setOrCreate('refreshMine', new Date().getTime().toString());

        await this.saveLoginState(userInfoStr);

        promptAction.showToast({ message: '登录成功', duration: 1500 });
        httpRequest.destroy();

        setTimeout(() => {
          // ✅ 清空栈并跳转
          this.pageStack.clear();
          this.pageStack.pushPathByName('LayoutPage', null, false);
        }, 500);
      } else {
        promptAction.showToast({ message: UserJson.message || '账号或密码错误', duration: 1500 });
        httpRequest.destroy();
      }
    } catch (error) {
      console.error('❌ 登录异常:', JSON.stringify(error));
      let errorMsg = '网络连接失败';
      if (error.toString().includes('timeout')) {
        errorMsg = '连接超时，请检查网络';
      }
      promptAction.showToast({ message: errorMsg, duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  async saveLoginState(userInfoStr: string) {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'user_prefs');
      await prefs.put('isLoggedIn', 'true');
      await prefs.put('userInfo', userInfoStr);
      await prefs.flush();
      console.log('✅ 登录状态已保存到本地存储');
    } catch (error) {
      console.error('❌ 保存登录状态失败:', error);
    }
  }
}

// ✅ 注意大小写：LoginPageBuilder（L和P大写）
@Builder
export function LoginPageBuilder() {
  Login()
}