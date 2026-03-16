import { pathStack } from '../commons/SystemConfig'

@Component
export struct Bill {

  build() {
    Column({ space: 16 }) {
      Text('账单')
        .fontSize(20)
        .fontWeight(700)

      Button('账单类型管理')
        .type(ButtonType.Capsule)
        .backgroundColor('#d81e06')
        .onClick(() => {
          pathStack.pushPath({
            name: 'BillType'
          })
        })
    }
    .padding(16)
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
