import { pathStack } from '../commons/SystemConfig'
import { BillDetailParams, BillEditParams, BillModel } from '../models/BillModel'
import { BillStore } from '../viewmodels/BillStore'

@Builder
export function BillDetailBuilder(name: string) {
  BillDetail()
}

@Component
export struct BillDetail {
  @State private bill: BillModel | undefined = undefined
  @State private showDeleteDialog: boolean = false

  private async loadBill(billId: string): Promise<void> {
    this.bill = await BillStore.findById(billId)
  }

  private async deleteBill(): Promise<void> {
    if (this.bill !== undefined) {
      await BillStore.remove(this.bill.id)
      this.showDeleteDialog = false
      pathStack.pop()
    }
  }

  @Builder
  private infoRow(label: string, value: string, color: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor('#999999')
        .width(80)
      Text(value)
        .fontSize(15)
        .fontColor(color)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }

  build() {
    NavDestination() {
      Stack() {
        if (this.bill === undefined) {
          Column() {
            Text('加载中...')
              .fontSize(14)
              .fontColor('#cccccc')
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Column({ space: 0 }) {
            Scroll() {
              Column({ space: 0 }) {
                // 金额展示
                Column({ space: 8 }) {
                  Row() {
                    Text(this.bill.ticon)
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#ffffff')
                  }
                  .width(56)
                  .height(56)
                  .backgroundColor(this.bill.type === 'expense' ? '#d81e06' : '#36ab60')
                  .borderRadius(28)
                  .justifyContent(FlexAlign.Center)

                  Text(`${this.bill.type === 'expense' ? '-' : '+'}¥${this.bill.money.toFixed(2)}`)
                    .fontSize(32)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.bill.type === 'expense' ? '#d81e06' : '#36ab60')
                    .margin({ top: 8 })

                  Text(this.bill.type === 'expense' ? '支出' : '收入')
                    .fontSize(13)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .padding({ top: 30, bottom: 24 })
                .width('100%')
                .alignItems(HorizontalAlign.Center)

                // 详情卡片
                Column() {
                  this.infoRow('类型', this.bill.tname, '#333333')
                  Divider().color('#f5f5f5')
                  this.infoRow('日期', this.bill.ctime, '#333333')
                  Divider().color('#f5f5f5')
                  this.infoRow('备注', this.bill.info.length > 0 ? this.bill.info : '无', '#666666')
                }
                .padding({ left: 20, right: 20, top: 4, bottom: 4 })
                .backgroundColor('#ffffff')
                .borderRadius(16)
                .margin(16)
                .shadow({
                  radius: 10,
                  color: 'rgba(0, 0, 0, 0.05)',
                  offsetX: 0,
                  offsetY: 2
                })
              }
            }
            .layoutWeight(1)
            .width('100%')

            // 底部操作按钮
            Row({ space: 12 }) {
              Button('删除')
                .layoutWeight(1)
                .height(46)
                .type(ButtonType.Capsule)
                .backgroundColor('#f5f5f5')
                .fontColor('#d81e06')
                .fontSize(15)
                .onClick(() => {
                  this.showDeleteDialog = true
                })

              Button('修改')
                .layoutWeight(1)
                .height(46)
                .type(ButtonType.Capsule)
                .backgroundColor(this.bill.type === 'expense' ? '#d81e06' : '#36ab60')
                .fontColor('#ffffff')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  if (this.bill !== undefined) {
                    const params: BillEditParams = {
                      mode: 'edit',
                      billId: this.bill.id
                    }
                    pathStack.pushPath({ name: 'BillEdit', param: params })
                  }
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 24 })
          }
          .height('100%')
          .width('100%')
          .backgroundColor('#f5f5f8')
        }

        // 删除确认弹窗
        if (this.showDeleteDialog) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.45)')
            .position({ x: 0, y: 0 })
            .onClick(() => {
              this.showDeleteDialog = false
            })

          Column({ space: 16 }) {
            Text('确认删除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text('删除后将无法恢复，确定要删除这条账单吗？')
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)

            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#f2f2f5')
                .fontColor('#666666')
                .type(ButtonType.Capsule)
                .onClick(() => {
                  this.showDeleteDialog = false
                })

              Button('确认删除')
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#d81e06')
                .fontColor('#ffffff')
                .type(ButtonType.Capsule)
                .onClick(async () => {
                  await this.deleteBill()
                })
            }
            .width('100%')
          }
          .padding(24)
          .width('80%')
          .backgroundColor('#ffffff')
          .borderRadius(20)
          .shadow({
            radius: 24,
            color: 'rgba(0, 0, 0, 0.15)',
            offsetX: 0,
            offsetY: 4
          })
        }
      }
    }
    .title('账单详情')
    .onReady(async (context: NavDestinationContext) => {
      const params: BillDetailParams | undefined = context.pathInfo?.param as BillDetailParams | undefined
      if (params !== undefined) {
        await this.loadBill(params.billId)
      }
    })
    .onShown(async () => {
      // 从编辑页返回时刷新数据
      if (this.bill !== undefined) {
        await this.loadBill(this.bill.id)
      }
    })
  }
}
