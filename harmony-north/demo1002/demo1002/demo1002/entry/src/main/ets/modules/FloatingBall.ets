import display from '@ohos.display';
import { AppStorageV2 } from '@kit.ArkUI';

@Component
export struct FloatingBall {
  @State isDragging: boolean = false;
  @State offsetX: number = 0;
  @State offsetY: number = 500;
  private startX: number = 0;
  private startY: number = 0;
  private screenWidth: number = 0;

  pageStack: NavPathStack = AppStorageV2.connect(NavPathStack, "pageStack", () => new NavPathStack())!

  async aboutToAppear() {
    const disp = await display.getDefaultDisplay();
    this.screenWidth = px2vp(disp.width);
  }

  build() {
    Stack() {
      // ========== 修改：用 Image 替换 Text ==========
      Image($r('app.media.floatBall'))  // 把图片放在 resources/base/media/ 目录下
        .width(60)
        .height(60)
        .borderRadius(30)
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          console.log('点击悬浮球，跳转到AIPage');
          this.pageStack.pushPathByName("AIPage", null, false);
        })
    }
    .width(60)
    .height(60)
    .position({ x: this.offsetX, y: this.offsetY })
    .zIndex(9999)
    .onTouch((event: TouchEvent) => {
      this.handleTouch(event);
      return true;
    })
  }

  private handleTouch(event: TouchEvent) {
    let touch = event.touches[0];
    switch (event.type) {
      case TouchType.Down:
        this.isDragging = true;
        this.startX = touch.x - this.offsetX;
        this.startY = touch.y - this.offsetY;
        event.stopPropagation();
        break;

      case TouchType.Move:
        if (this.isDragging) {
          const newX = touch.x - this.startX;
          const newY = touch.y - this.startY;
          this.offsetX = Math.max(0, newX);
          this.offsetX = Math.min(this.screenWidth - 60, this.offsetX);
          this.offsetY = Math.max(0, newY);
        }
        event.stopPropagation();
        break;

      case TouchType.Up:
      case TouchType.Cancel:
        this.isDragging = false;
        if (this.offsetX + 30 > this.screenWidth / 2) {
          this.offsetX = this.screenWidth - 60;
        } else {
          this.offsetX = 0;
        }
        event.stopPropagation();
        break;
    }
  }
}