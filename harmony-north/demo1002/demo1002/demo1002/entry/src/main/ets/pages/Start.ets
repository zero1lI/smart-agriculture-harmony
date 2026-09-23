import  {AppStorageV2} from "@kit.ArkUI"
// 第2步：暴露出去
@Builder
export function StartPageBuilder() {
  Start();
}


@Component
struct Start{
  // 定义的倒计时  属性  死变量
  // counts:number=8
  // 定义的倒计时  属性  活变量
  @State counts: number = 8
  timerId: number = -1
  // 创建一个导航控制器对象并传入Navigation
  pageStack: NavPathStack = AppStorageV2.connect(
    NavPathStack,
    "pageStack",
    () => new NavPathStack()
  )!

  // 设计页面
  build() {
    //第一步：先告诉NavDestination
    NavDestination(){
      //堆叠图
      Stack({alignContent:Alignment.TopEnd}){
        // 布局广告
        Image($r("app.media.start"))
          .width("100%")
          .height("100%")


        //跳过按钮
        Text("跳过"+this.counts)
          .fontColor("#fff")
          .border({width:1,radius:10})
          .backgroundColor("#B2A496")
          .padding(5)
          .margin(10)
          .onClick(()=>{

            clearInterval(this.timerId)
            //跳转到首页
            this.pageStack.replacePathByName("HomePage",null,false)
          })
      }

    }
    .width("100%")
    .height("100%")
  }

  //页面加载的时候就调用
  aboutToAppear(): void {
    this.startCountdown()
  }

  aboutToDisappear(): void {
    this.clearTimer()
  }

  clearTimer(): void {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId)  // 注意这里是 clearTimeout
      this.timerId = -1
    }
  }

  // 使用 setTimeout 递归实现倒计时
  startCountdown(): void {
    this.timerId = setTimeout(() => {
      if (this.counts <= 1) {
        this.pageStack.replacePathByName("HomePage", null, false)
      } else {
        this.counts--
        this.startCountdown()  // 递归调用
      }
    }, 1000)
  }
}