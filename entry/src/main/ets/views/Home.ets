import { pathStack } from '../commons/SystemConfig'
import { BillSummary, BillEditParams } from '../models/BillModel'
import { AssetSummary } from '../models/AssetModel'
import { HealthStatus, Insight, HomeStore } from '../viewmodels/HomeStore'

@Component
export struct Home {
  @State private currentMonth: string = ''
  @State private income: number = 0
  @State private expense: number = 0
  @State private balance: number = 0
  @State private assetSummary: AssetSummary = new AssetSummary()
  @State private healthStatus: HealthStatus = HealthStatus.NORMAL
  @State private insight: Insight | null = null
  @State private isLoading: boolean = true

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    this.currentMonth = await HomeStore.getCurrentMonth()
    const summary: BillSummary = await HomeStore.getMonthSummary(this.currentMonth)
    this.income = summary.income
    this.expense = summary.expense
    this.balance = HomeStore.calculateBalance(summary)

    this.assetSummary = await HomeStore.getAssetSummary()
    this.healthStatus = await HomeStore.evaluateHealthStatus()
    this.insight = await HomeStore.generateInsight()

    this.isLoading = false
  }

  private getMonthLabel(): string {
    const parts: string[] = this.currentMonth.split('-')
    return `${parts[0]}年${parseInt(parts[1])}月`
  }

  private getHealthLabel(): string {
    switch (this.healthStatus) {
      case HealthStatus.NORMAL:
        return '财务状况良好'
      case HealthStatus.ATTENTION:
        return '需要关注'
      case HealthStatus.WARNING:
        return '支出预警'
    }
  }

  private getHealthIcon(): string {
    switch (this.healthStatus) {
      case HealthStatus.NORMAL:
        return '✓'
      case HealthStatus.ATTENTION:
        return '!'
      case HealthStatus.WARNING:
        return '⚠'
    }
  }

  private getHealthColor(): string {
    switch (this.healthStatus) {
      case HealthStatus.NORMAL:
        return '#36ab60'
      case HealthStatus.ATTENTION:
        return '#ff9800'
      case HealthStatus.WARNING:
        return '#d81e06'
    }
  }

  private getInsightBgColor(): string {
    if (!this.insight) return '#ffffff'
    switch (this.insight.type) {
      case 'warning':
        return '#fff5f5'
      case 'attention':
        return '#fffbf0'
      case 'info':
        return '#f5faff'
    }
  }

  private getInsightBorderColor(): string {
    if (!this.insight) return '#e0e0e0'
    switch (this.insight.type) {
      case 'warning':
        return '#d81e06'
      case 'attention':
        return '#ff9800'
      case 'info':
        return '#4a90d9'
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.BalanceCard()
          this.HealthStatusCard()
          if (this.insight) {
            this.InsightCard()
          }
          this.AssetSummaryCard()
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      this.AddBillButton()
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f8')
  }

  @Builder
  BalanceCard() {
    Column({ space: 12 }) {
      Text(this.getMonthLabel())
        .fontSize(13)
        .fontColor('#999999')

      Text(this.balance >= 0 ? `¥ ${this.balance.toFixed(2)}` : `-¥ ${Math.abs(this.balance).toFixed(2)}`)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.balance >= 0 ? '#333333' : '#d81e06')

      Text('本月结余')
        .fontSize(12)
        .fontColor('#999999')

      Divider()
        .color('#eeeeee')
        .margin({ top: 8, bottom: 4 })

      Row() {
        Column({ space: 4 }) {
          Text('收入')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.income.toFixed(2)}`)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#36ab60')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 4 }) {
          Text('支出')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.expense.toFixed(2)}`)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#d81e06')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#ffffff')
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  HealthStatusCard() {
    Row({ space: 10 }) {
      Text(this.getHealthIcon())
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getHealthColor())
        .backgroundColor(this.getHealthColor())
        .padding(4)
        .borderRadius(10)

      Text(this.getHealthLabel())
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      Blank()

      Text(this.currentMonth)
        .fontSize(11)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#ffffff')
    .borderRadius(12)
  }

  @Builder
  InsightCard() {
    Column({ space: 8 }) {
      Row() {
        Text('💡')
          .fontSize(14)

        Text('智能提醒')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 6 })

        Blank()

        Text(this.insight?.actionText || '查看')
          .fontSize(11)
          .fontColor(this.getInsightBorderColor())
          .onClick(() => {
            pathStack.pushPath({ name: 'Bill' })
          })
      }

      Text(this.insight?.message || '')
        .fontSize(13)
        .fontColor('#333333')
        .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.getInsightBgColor())
    .borderRadius(12)
    .border({ width: 1, color: this.getInsightBorderColor() })
  }

  @Builder
  AssetSummaryCard() {
    Column({ space: 10 }) {
      Row() {
        Text('资产概况')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        Text('查看详情 ›')
          .fontSize(11)
          .fontColor('#4a90d9')
          .onClick(() => {
            pathStack.pushPathByName('AssetStat', undefined)
          })
      }
      .width('100%')

      Divider()
        .color('#f0f0f0')

      Row() {
        Column({ space: 4 }) {
          Text('总资产')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.assetSummary.asset.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#36ab60')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text('净资产')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.assetSummary.net.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.assetSummary.net >= 0 ? '#36ab60' : '#d81e06')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 4 }) {
          Text('负债')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.assetSummary.liability.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.assetSummary.liability > 0 ? '#d81e06' : '#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#ffffff')
    .borderRadius(12)
  }

  @Builder
  AddBillButton() {
    Row() {
      Text('+ 记一笔')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#ffffff')
    }
    .width('80%')
    .height(50)
    .backgroundColor('#36ab60')
    .borderRadius(25)
    .justifyContent(FlexAlign.Center)
    .shadow({
      radius: 20,
      color: 'rgba(54, 171, 96, 0.35)',
      offsetX: 0,
      offsetY: 8
    })
    .position({ bottom: 20 })
    .onClick(() => {
      const params: BillEditParams = { mode: 'create' }
      pathStack.pushPath({ name: 'BillEdit', param: params })
    })
  }
}
