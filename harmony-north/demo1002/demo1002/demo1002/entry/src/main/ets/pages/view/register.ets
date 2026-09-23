// Register.ets
import promptAction from '@ohos.promptAction';
import  {AppStorageV2} from "@kit.ArkUI"
import { http } from '@kit.NetworkKit';

interface UserType{
  user_id:number,
  username:string,
  password:string,
  phone:string,
  email:string,
  times:string
}

interface UserData{
  code:number,
  data:UserType,
  message:string
}


@Component
struct Register {
  // 创建一个导航控制器对象并传入Navigation
  pageStack: NavPathStack =AppStorageV2.connect(NavPathStack,"pageStack",()=>new NavPathStack())!

  @State username: string = 'xiaohong';
  @State email: string = '64565633@qq.com';
  @State phone: string = '13256481234';
  @State password: string = '123456';


  build() {
    NavDestination() {
      Column() {
        // 返回按钮
        Row() {
          Text('‹')
            .fontSize(30)
            .fontColor('#2d6a4f')
            .onClick(() => {
              this.pageStack.pop();
            })

          Blank()

          Text('注册')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1b4a1b')

          Blank()
          Text('')
        }
        .width('100%')
        .padding(16)
        .margin({ bottom: 30 })

        // Logo
        Column() {
          Text('🌾')
            .fontSize(70)
            .margin({ bottom: 10 })
          Text('智慧农业')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1b4a1b')
        }
        .width('100%')
        .margin({ bottom: 40 })

        // 表单
        Column() {
          TextInput({ placeholder: '用户名（至少6位）', text: this.username })
            .width('100%')
            .height(50)
            .fontSize(16)
            .backgroundColor('#f5faf5')
            .borderRadius(12)
            .padding({ left: 16 })
            .type(InputType.USER_NAME)
            .maxLength(18)
            .onChange((value: string) => {
              this.username = value;
            })
            .margin({ bottom: 16 })

          // 密码
          TextInput({ placeholder: '密码（至少6位）', text: this.password })
            .width('100%')
            .height(50)
            .fontSize(16)
            .backgroundColor('#f5faf5')
            .borderRadius(12)
            .padding({ left: 16 })
            .type(InputType.Password)
            .maxLength(18)
            .onChange((value: string) => {
              this.password = value;
            })
            .margin({ bottom: 30 })

          // 手机号
          TextInput({ placeholder: '手机号', text: this.phone })
            .width('100%')
            .height(50)
            .fontSize(16)
            .backgroundColor('#f5faf5')
            .borderRadius(12)
            .padding({ left: 16 })
            .type(InputType.PhoneNumber)
            .maxLength(11)
            .onChange((value: string) => {
              this.phone = value;
            })
            .margin({ bottom: 30 })

          //邮箱
          TextInput({ placeholder: '邮箱', text: this.email })
            .width('100%')
            .height(50)
            .fontSize(16)
            .backgroundColor('#f5faf5')
            .borderRadius(12)
            .padding({ left: 16 })
            .type(InputType.Email)
            .maxLength(18)
            .onChange((value: string) => {
              this.email = value;
            })
            .margin({ bottom: 30 })

          // 注册按钮
          Button('注册')
            .width('100%')
            .height(48)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#2d6a4f')
            .borderRadius(12)
            .onClick(() => {
              this.handleRegister();
            })

          // 登录跳转
          Row() {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#666')
            Text('去登录')
              .fontSize(14)
              .fontColor('#2d6a4f')
              .fontWeight(FontWeight.Medium)
              .onClick(() => {
                this.pageStack.pushPathByName("LoginPage",null,false);
              })
          }
          .margin({ top: 20 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#ffffff')
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .backgroundColor('#f5faf5')
    }
    .title('')
    .hideTitleBar(true)
  }

  // 去注册的方法
  async  handleRegister() {
    if (!this.phone || this.phone.length !== 11) {
      promptAction.showToast({ message: '请输入正确手机号' });
      return;
    }
    if (!this.password || this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6位' });
      return;
    }

    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

    if (!this.email || !emailRegex.test(this.email)) {
      promptAction.showToast({ message: '请输入正确的邮箱' });
      return;
    }

    // 保存用户信息
    // const userInfo:UserType = {
    //   username: '用户' + this.phone.substring(7),
    //   phone: this.phone,
    //   email:this.email
    // };
    // AppStorage.setOrCreate('userInfo', JSON.stringify(userInfo));
    //创建请求后台的http对象
    let httpRequest=http.createHttp()

    //发送请求  :  必然就有返回值  （回调函数）
    const responseData= await httpRequest.request(
      //填写HTTP请求的URL地址，可以带参数或不带参数。URL地址由开发者自定义。请求的参数可以在extraData中指定。
      //localhost:指的是本机ip地址     http://127.0.0.1:8080/api/login   get post
      "http://192.168.99.46:8080/api/user/register",
      {
        method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET，用于从服务器获取数据，而POST方法用于向服务器上传数据。
        // 开发者根据自身业务需要添加header字段。
        header: {
          'Content-Type': 'application/json'
        },
        extraData:{
          username:this.username,
          password:this.password,
          email:this.email,
          phone:this.phone
        },
        //可选，指定返回数据的类型
        expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型。
      }
    )
    // 输出返回数据
    //{"code":200,"data":{"email":"657596011@qq.com","password":"123456","phone":"15035451125",
    // "times":"2026-07-17 15:20:46","user_id":7,"username":"xiaoming"},
    // "message":"注册成功"}
    console.log(responseData.result.toString())
    //解析传过来的json数据
    const UserJson:UserData= JSON.parse(responseData.result.toString())
    //判断
    if(UserJson.code===200){
      // 谈消息
      promptAction.showToast({ message: UserJson.message });
      //成功之后？？？
      this.pageStack.pushPathByName("loginPage",null,false)
    }else{
      // 谈消息
      promptAction.showToast({ message: UserJson.message });
    }
  }
}
@Builder
export function RegisterPageBuilder() {
  Register();
}
