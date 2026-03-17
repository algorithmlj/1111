import { pathStack } from '../commons/SystemConfig'
import { BillEditParams } from '../commons/BillModel'
import { BillStore } from '../commons/BillStore'

@Component
export struct Bill {
  @State private monthExpense: number = 0
  @State private monthIncome: number = 0

  aboutToAppear() {
    this.refreshSummary()
  }

  private async refreshSummary(): Promise<void> {
    const now: Date = new Date()
    const y: string = now.getFullYear().toString()
    const m: string = (now.getMonth() + 1).toString().padStart(2, '0')
    const month: string = `${y}-${m}`
    const summary: Record<string, number> = await BillStore.sumByMonth(month)
    this.monthExpense = summary.expense
    this.monthIncome = summary.income
  }

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
            Text(`¥ ${this.monthExpense.toFixed(2)}`)
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
            Text(`¥ ${this.monthIncome.toFixed(2)}`)
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
          // 记一笔
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
          .onClick(() => {
            const params: BillEditParams = { mode: 'create' }
            pathStack.pushPath({ name: 'BillEdit', param: params })
          })

          // 账单列表
          Column({ space: 8 }) {
            Row() {
              Text('单')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ffffff')
            }
            .width(44)
            .height(44)
            .backgroundColor('#4a90d9')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Text('账单列表')
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
            pathStack.pushPath({ name: 'BillList' })
          })

          // 类型管理
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
        }
        .width('100%')
      }
      .width('100%')
    }
    .padding(16)
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f8')
    .onAppear(() => {
      this.refreshSummary()
    })
  }
}
