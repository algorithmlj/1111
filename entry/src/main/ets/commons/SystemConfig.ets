import { BarModel } from '../commons/BarModel'
export const pathStack:NavPathStack = new NavPathStack()
export class SystemConfig{
  //底部导航的内容
  public static bars:BarModel[]=[
    {
      name:"首页",
      img1:"app.media.zhuye",
      img2:"app.media.zhuye1",
      color1:"#707070",
      color2:"#d81e06"
    },
    {
      name:"账单",
      img1:"app.media.zhangdan",
      img2:"app.media.zhangdan1",
      color1:"#707070",
      color2:"#d81e06"
    },
    {
      name:"AI管家",
      img1:"app.media.xiaoaiguanjia",
      img2:"app.media.xiaoaiguanjia1",
      color1:"#707070",
      color2:"#d81e06"
    },
    {
      name:"资产",
      img1:"app.media.zichan",
      img2:"app.media.zichan1",
      color1:"#707070",
      color2:"#d81e06"
    },
    {
      name:"统计",
      img1:"app.media.tongji",
      img2:"app.media.tongji1",
      color1:"#707070",
      color2:"#d81e06"
    },
  ]
}