import { pathStack } from '../commons/SystemConfig'

@Component
export struct Bill {
  build() {
    Column({ space: 20 }) {
      // 顶部概览卡片
      Column({ space: 12 }) {
        Text('本月账单概览')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')

        Row() {
          Column({ space: 4 }) {
            Text('支出')
              .fontSize(12)
              .fontColor('#999999')
            Text('¥ 0.00')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#d81e06')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Divider()
            .vertical(true)
            .height(36)
            .color('#eeeeee')

          Column({ space: 4 }) {
            Text('收入')
              .fontSize(12)
              .fontColor('#999999')
            Text('¥ 0.00')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#36ab60')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }
      .padding(20)
      .width('100%')
      .backgroundColor('#ffffff')
      .borderRadius(16)
      .shadow({
        radius: 12,
        color: 'rgba(0, 0, 0, 0.06)',
        offsetX: 0,
        offsetY: 2
      })

      // 快捷功能区
      Column({ space: 12 }) {
        Text('快捷功能')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')

        Row({ space: 12 }) {
          // 账单类型管理
          Column({ space: 8 }) {
            Row() {
              Text('类')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
            }
            .width(44)
            .height(44)
            .backgroundColor('#d81e06')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Text('类型管理')
              .fontSize(13)
              .fontColor('#555555')
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })
          .onClick(() => {
            pathStack.pushPath({ name: 'BillType' })
          })

          // 记一笔（占位）
          Column({ space: 8 }) {
            Row() {
              Text('+')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
            }
            .width(44)
            .height(44)
            .backgroundColor('#36ab60')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Text('记一笔')
              .fontSize(13)
              .fontColor('#555555')
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })

          // 统计（占位）
          Column({ space: 8 }) {
            Row() {
              Text('统')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
            }
            .width(44)
            .height(44)
            .backgroundColor('#4a90d9')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Text('月度统计')
              .fontSize(13)
              .fontColor('#555555')
          }
          .layoutWeight(1)
          .padding({ top: 16, bottom: 16 })
          .backgroundColor('#ffffff')
          .borderRadius(14)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })
        }
        .width('100%')
      }
      .width('100%')

      // 最近账单（占位）
      Column({ space: 12 }) {
        Text('最近账单')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')

        Column() {
          Text('暂无账单记录')
            .fontSize(14)
            .fontColor('#cccccc')
        }
        .padding(40)
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(14)
        .alignItems(HorizontalAlign.Center)
        .shadow({
          radius: 8,
          color: 'rgba(0, 0, 0, 0.05)',
          offsetX: 0,
          offsetY: 2
        })
      }
      .width('100%')
    }
    .padding(16)
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f8')
  }
}
