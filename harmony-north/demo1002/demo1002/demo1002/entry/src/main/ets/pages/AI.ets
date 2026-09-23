import web_webview from '@ohos.web.webview';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';

// 跳转页面入口函数
@Builder
export function aiPageBuilder() {
  aiPage();
}

@Component
export struct aiPage {
  pathStack: NavPathStack = new NavPathStack();
  //获取WebviewController对象
  webController: web_webview.WebviewController = new web_webview.WebviewController();
  context = getContext(this) as common.UIAbilityContext;

  async aboutToAppear() {
    // 动态申请系统麦克风权限
    const atManager = abilityAccessCtrl.createAtManager();
    await atManager.requestPermissionsFromUser(this.context, ['ohos.permission.MICROPHONE']);
  }
  //模板设计
  build() {
    NavDestination(){
      Stack(){
        Column() {
          // Web组件加载 赣农智能体
          Web({
            src:"http://192.168.235.128:8080/chat/5204dc94ae827c93?mode=mobile",
            controller:this.webController
          })
            .javaScriptAccess(true)
            .zoomAccess(true)
            .domStorageAccess(true)
            .geolocationAccess(true)
            .width("100%")
            .height(650)
        }
        .width('100%')
        .height('100%')
      }

    }
    .title(`农业管理 智能客服`)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}
