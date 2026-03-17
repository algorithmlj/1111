import { pathStack } from '../commons/SystemConfig'
import { BillDetailParams, BillEditParams, BillModel, BillSummary } from '../commons/BillModel'
import { BillTypeKind } from '../commons/BillTypeModel'
import { BillStore } from '../commons/BillStore'

@Builder
export function BillListBuilder(name: string) {
  BillList()
}

@Component
export struct BillList {
  @State private currentMonth: string = ''
  @State private filterType: BillTypeKind | 'all' = 'all'
  @State private bills: BillModel[] = []
  @State private totalIncome: number = 0
  @State private totalExpense: number = 0

  aboutToAppear() {
    const now: Date = new Date()
    const y: string = now.getFullYear().toString()
    const m: string = (now.getMonth() + 1).toString().padStart(2, '0')
    this.currentMonth = `${y}-${m}`
    this.refreshData()
  }

  private async refreshData(): Promise<void> {
    this.bills = await BillStore.list(this.currentMonth, this.filterType)
    const summary: BillSummary = await BillStore.sumByMonth(this.currentMonth)
    this.totalIncome = summary.income
    this.totalExpense = summary.expense
  }

  private changeMonth(delta: number): void {
    const parts: string[] = this.currentMonth.split('-')
    let year: number = parseInt(parts[0])
    let month: number = parseInt(parts[1]) + delta
    if (month > 12) {
      year++
      month = 1
    } else if (month < 1) {
      year--
      month = 12
    }
    this.currentMonth = `${year}-${month.toString().padStart(2, '0')}`
    this.refreshData()
  }

  build() {
    NavDestination() {
      Column({ space: 0 }) {
        // 月份切换 + 统计
        Column({ space: 12 }) {
          Row() {
            Text('<')
              .fontSize(20)
              .fontColor('#666666')
              .padding(8)
              .onClick(() => {
                this.changeMonth(-1)
              })

            Text(this.currentMonth)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Text('>')
              .fontSize(20)
              .fontColor('#666666')
              .padding(8)
              .onClick(() => {
                this.changeMonth(1)
              })
          }
          .width('100%')

          Row() {
            Column({ space: 2 }) {
              Text('支出')
                .fontSize(11)
                .fontColor('#999999')
              Text(`¥ ${this.totalExpense.toFixed(2)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#d81e06')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider().vertical(true).height(28).color('#eeeeee')

            Column({ space: 2 }) {
              Text('收入')
                .fontSize(11)
                .fontColor('#999999')
              Text(`¥ ${this.totalIncome.toFixed(2)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#36ab60')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider().vertical(true).height(28).color('#eeeeee')

            Column({ space: 2 }) {
              Text('结余')
                .fontSize(11)
                .fontColor('#999999')
              Text(`¥ ${(this.totalIncome - this.totalExpense).toFixed(2)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#4a90d9')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 4, bottom: 4 })
        }
        .padding(16)
        .backgroundColor('#ffffff')
        .shadow({
          radius: 8,
          color: 'rgba(0, 0, 0, 0.05)',
          offsetX: 0,
          offsetY: 2
        })

        // 类型筛选 Tab
        Row({ space: 0 }) {
          Text('全部')
            .fontSize(13)
            .fontWeight(this.filterType === 'all' ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.filterType === 'all' ? '#ffffff' : '#666666')
            .backgroundColor(this.filterType === 'all' ? '#4a90d9' : Color.Transparent)
            .borderRadius(14)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .onClick(async () => {
              this.filterType = 'all'
              await this.refreshData()
            })

          Text('支出')
            .fontSize(13)
            .fontWeight(this.filterType === 'expense' ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.filterType === 'expense' ? '#ffffff' : '#666666')
            .backgroundColor(this.filterType === 'expense' ? '#d81e06' : Color.Transparent)
            .borderRadius(14)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .onClick(async () => {
              this.filterType = 'expense'
              await this.refreshData()
            })

          Text('收入')
            .fontSize(13)
            .fontWeight(this.filterType === 'income' ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.filterType === 'income' ? '#ffffff' : '#666666')
            .backgroundColor(this.filterType === 'income' ? '#36ab60' : Color.Transparent)
            .borderRadius(14)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .onClick(async () => {
              this.filterType = 'income'
              await this.refreshData()
            })

          Blank()

          // 新增按钮
          Text('+ 记一笔')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ffffff')
            .backgroundColor('#d81e06')
            .borderRadius(14)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .onClick(() => {
              const params: BillEditParams = { mode: 'create' }
              pathStack.pushPath({ name: 'BillEdit', param: params })
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 6 })

        // 账单列表
        if (this.bills.length === 0) {
          Column({ space: 12 }) {
            Text('( . _ . )')
              .fontSize(40)
              .fontColor('#dddddd')
            Text('本月暂无账单记录')
              .fontSize(14)
              .fontColor('#bbbbbb')
          }
          .layoutWeight(1)
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 8 }) {
            ForEach(this.bills, (item: BillModel) => {
              ListItem() {
                Row() {
                  // 图标
                  Row() {
                    Text(item.ticon)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#ffffff')
                  }
                  .width(40)
                  .height(40)
                  .backgroundColor(item.type === 'expense' ? '#d81e06' : '#36ab60')
                  .borderRadius(20)
                  .justifyContent(FlexAlign.Center)
                  .margin({ right: 12 })

                  // 类型名 + 日期
                  Column({ space: 4 }) {
                    Text(item.tname)
                      .fontSize(15)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                    Text(item.ctime)
                      .fontSize(11)
                      .fontColor('#bbbbbb')
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  // 金额
                  Text(`${item.type === 'expense' ? '-' : '+'}¥${item.money.toFixed(2)}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(item.type === 'expense' ? '#d81e06' : '#36ab60')
                }
                .padding({ left: 14, right: 14, top: 14, bottom: 14 })
                .width('100%')
                .backgroundColor('#ffffff')
                .borderRadius(14)
                .shadow({
                  radius: 6,
                  color: 'rgba(0, 0, 0, 0.04)',
                  offsetX: 0,
                  offsetY: 2
                })
                .onClick(() => {
                  const params: BillDetailParams = { billId: item.id }
                  pathStack.pushPath({ name: 'BillDetail', param: params })
                })
              }
            }, (item: BillModel): string => item.id)
          }
          .padding({ left: 16, right: 16, top: 8 })
          .layoutWeight(1)
          .width('100%')
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#f5f5f8')
    }
    .title('账单列表')
    .onShown(() => {
      this.refreshData()
    })
  }
}
