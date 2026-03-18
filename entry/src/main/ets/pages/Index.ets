import { BarModel } from '../models/BarModel'
import { pathStack, SystemConfig } from '../commons/SystemConfig'
import { AIManager } from '../views/AIManager'
import { Assets } from '../views/Assets'
import { Bill } from '../views/Bill'
import { Home } from '../views/Home'
import { Statistic } from '../views/Statistic'

@Entry
@Component
struct Index {
  //底部导航的内容
  bars:BarModel[]=SystemConfig.bars
  @State index:number=0

  @Builder createBar(i:number){
    Column({space:5}){
      if(i==this.index){
        //选中
        Image($r(this.bars[i].img2))
          .width(30)
        Text(this.bars[i].name)
          .fontColor(this.bars[i].color2)
      }else {
        //未选中
        Image($r(this.bars[i].img1))
          .width(30)
        Text(this.bars[i].name)
          .fontColor(this.bars[i].color1)
      }
    }
  }

  build() {
    Navigation(pathStack){
      Column({space:10}) {
        Tabs(){
          TabContent(){
            Home()
          }.tabBar(this.createBar(0))
          TabContent(){
            Bill()
          }.tabBar(this.createBar(1))
          TabContent(){
            AIManager()
          }.tabBar(this.createBar(2))
          TabContent(){
            Assets()
          }.tabBar(this.createBar(3))
          TabContent(){
            Statistic()
          }.tabBar(this.createBar(4))
        }
        .barPosition(BarPosition.End)
        .onChange(v=>{
          this.index=v;
        })

      }
      .height('100%')
      .width('100%')
    }
    .title(this.bars[this.index].name)
    .titleMode(NavigationTitleMode.Mini)
    //隐藏返回图标
    .hideBackButton(true)
  }
}
