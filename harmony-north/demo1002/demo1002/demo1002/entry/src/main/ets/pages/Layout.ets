
import { Home } from "./tarBar/Home"
import { Dev } from "./tarBar/Dev"
import { Mine } from "./tarBar/Mine"


interface TarBarType {
  title: string,
  icon_active: Resource,
  icon: Resource
}

@Builder
export function LayoutPageBuilder() {
  Layout()
}

@Component
struct Layout {
  @State currentIndex: number = 0

  tarBarData: TarBarType[] = [
    {
      title: "首页",
      icon_active: $rawfile("tarbar/icon_home_active.png"),
      icon: $rawfile("tarbar/icon_home.png")
    },
    {
      title: "设备",
      icon_active: $rawfile("tarbar/icon_dev_active.png"),
      icon: $rawfile("tarbar/icon_dev.png")
    },
    {
      title: "我的",
      icon_active: $rawfile("tarbar/icon_mine_active.png"),
      icon: $rawfile("tarbar/icon_mine.png")
    }
  ]

  build() {
    NavDestination() {
      Tabs({barPosition:BarPosition.End,index:this.currentIndex}){
        // 首页
        TabContent(){
          Home()
        }.tabBar(this.TarBarPosition(0))


        //设备控制也
        TabContent(){
          Dev()
        }.tabBar(this.TarBarPosition(1))

        //我的页面
        TabContent(){
          Mine()
        }.tabBar(this.TarBarPosition(2))
      }
      // 每次切换的时候，都要赋值给上边
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(60)
      .backgroundColor('#FFFFFF')
      .onChange((index)=>{
        this.currentIndex=index
      })

    }

  }


  @Builder
  TarBarPosition(index: number) {
    Column() {
      // 小图标
      Image(this.currentIndex === index ?
        this.tarBarData[index].icon_active :
        this.tarBarData[index].icon)
        .width(26)
        .height(26)
        .objectFit(ImageFit.Contain)

      // 文字描述
      Text(this.tarBarData[index].title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? "#4CAF50" : "#999999")
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}