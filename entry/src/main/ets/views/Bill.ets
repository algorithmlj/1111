import { pathStack } from '../commons/SystemConfig'
import { BillDetailParams, BillEditParams, BillModel, BillSummary } from '../commons/BillModel'
import { BillTypeKind } from '../commons/BillTypeModel'
import { BillStore } from '../commons/BillStore'

@Component
export struct Bill {
  @State private currentMonth: string = ''
  @State private filterType: BillTypeKind | 'all' = 'all'
  @State private bills: BillModel[] = []
  @State private totalIncome: number = 0
  @State private totalExpense: number = 0
  @State private showMonthPicker: boolean = false
  @State private showTypePicker: boolean = false

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

  private getFilterLabel(): string {
    if (this.filterType === 'all') {
      return '全部'
    } else if (this.filterType === 'expense') {
      return '支出'
    } else {
      return '收入'
    }
  }

  private getMonthDisplay(): string {
    const parts: string[] = this.currentMonth.split('-')
    return `${parts[0]}年${parseInt(parts[1])}月`
  }

  build() {
    Stack() {
      Column({ space: 0 }) {
        // ── 顶部收支总览 + 类型管理入口 ──
        Column({ space: 12 }) {
          Row() {
            Blank()

            // 类型管理入口（小图标按钮）
            Row({ space: 4 }) {
              Text('⚙')
                .fontSize(16)
                .fontColor('#888888')
              Text('类型管理')
                .fontSize(12)
                .fontColor('#888888')
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor('#f2f2f5')
            .borderRadius(16)
            .onClick(() => {
              pathStack.pushPath({ name: 'BillType' })
            })
          }
          .width('100%')

          // 收入 / 支出 统计
          Row() {
            Column({ space: 4 }) {
              Text('总收入')
                .fontSize(11)
                .fontColor('#999999')
              Text(`¥ ${this.totalIncome.toFixed(2)}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#36ab60')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Divider()
              .vertical(true)
              .height(32)
              .color('#eeeeee')

            Column({ space: 4 }) {
              Text('总支出')
                .fontSize(11)
                .fontColor('#999999')
              Text(`¥ ${this.totalExpense.toFixed(2)}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#d81e06')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        }
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .width('100%')
        .backgroundColor('#ffffff')
        .shadow({
          radius: 8,
          color: 'rgba(0, 0, 0, 0.05)',
          offsetX: 0,
          offsetY: 2
        })

        // ── 筛选栏：月份选择 + 类型选择 ──
        Row({ space: 10 }) {
          // 月份选择器
          Row() {
            Text('<')
              .fontSize(16)
              .fontColor('#888888')
              .padding({ right: 4 })
              .onClick(() => {
                this.changeMonth(-1)
              })

            Text(this.getMonthDisplay())
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Text('>')
              .fontSize(16)
              .fontColor('#888888')
              .padding({ left: 4 })
              .onClick(() => {
                this.changeMonth(1)
              })
          }
          .height(34)
          .padding({ left: 12, right: 12 })
          .backgroundColor('#ffffff')
          .borderRadius(17)
          .border({ width: 0.5, color: '#e0e0e0' })
          .justifyContent(FlexAlign.Center)

          // 类型筛选器
          Row({ space: 0 }) {
            Text('全部')
              .fontSize(12)
              .fontWeight(this.filterType === 'all' ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.filterType === 'all' ? '#ffffff' : '#666666')
              .backgroundColor(this.filterType === 'all' ? '#4a90d9' : Color.Transparent)
              .borderRadius(14)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .onClick(async () => {
                this.filterType = 'all'
                await this.refreshData()
              })

            Text('支出')
              .fontSize(12)
              .fontWeight(this.filterType === 'expense' ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.filterType === 'expense' ? '#ffffff' : '#666666')
              .backgroundColor(this.filterType === 'expense' ? '#d81e06' : Color.Transparent)
              .borderRadius(14)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .onClick(async () => {
                this.filterType = 'expense'
                await this.refreshData()
              })

            Text('收入')
              .fontSize(12)
              .fontWeight(this.filterType === 'income' ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.filterType === 'income' ? '#ffffff' : '#666666')
              .backgroundColor(this.filterType === 'income' ? '#36ab60' : Color.Transparent)
              .borderRadius(14)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .onClick(async () => {
                this.filterType = 'income'
                await this.refreshData()
              })
          }
          .height(34)
          .padding({ left: 2, right: 2 })
          .backgroundColor('#f5f5f8')
          .borderRadius(17)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 6 })

        // ── 账单列表 ──
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
          .padding({ left: 16, right: 16, top: 8, bottom: 80 })
          .layoutWeight(1)
          .width('100%')
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#f5f5f8')

      // ── FAB 悬浮按钮：记一笔 ──
      Row() {
        Text('+')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
      }
      .width(56)
      .height(56)
      .backgroundColor('#36ab60')
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)
      .shadow({
        radius: 16,
        color: 'rgba(54, 171, 96, 0.4)',
        offsetX: 0,
        offsetY: 6
      })
      .position({ right: 20, bottom: 24 })
      .onClick(() => {
        const params: BillEditParams = { mode: 'create' }
        pathStack.pushPath({ name: 'BillEdit', param: params })
      })
    }
    .height('100%')
    .width('100%')
    .onAppear(() => {
      this.refreshData()
    })
  }
}
