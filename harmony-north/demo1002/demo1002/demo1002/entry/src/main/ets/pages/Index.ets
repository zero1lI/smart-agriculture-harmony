// Index.ets
import { AppStorageV2 } from "@kit.ArkUI"
import { DeviceManage } from "./device/DeviceManage"

@Entry
@Component
struct Index {
  // 创建一个导航控制器对象并传入Navigation
  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text('加载中...')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .onAppear(() => {
      console.info('Navigation appeared, navigating to StartPage')

      // 不需要 setPages，routerMap 已经配置好了
      this.pageStack.replacePathByName("StartPage", null, false)
    })
    .hideNavBar(true)
    .width('100%')
    .height('100%')
  }
}
// pages/device/DeviceManage.ets

// ... 你之前的 DeviceManage 组件代码 ...

// ========== 在文件末尾添加 Builder 导出 ==========
@Builder
export function DeviceManagePageBuilder() {
  DeviceManage()
}