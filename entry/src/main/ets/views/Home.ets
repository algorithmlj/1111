import { pathStack } from '../commons/SystemConfig'
import { BillSummary, BillEditParams } from '../models/BillModel'
import { AssetSummary } from '../models/AssetModel'
import { HealthStatus, Insight, HomeStore } from '../viewmodels/HomeStore'

@Component
export struct Home {
  // 父组件传入的当前 Tab 索引，用于监听切换
  @Prop @Watch('onTabChanged') currentTabIndex: number = 0
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

  /**
   * Tab 切换时触发，当切换到首页 Tab（index=0）时刷新数据
   */
  onTabChanged(): void {
    if (this.currentTabIndex === 0) {
      this.loadData()
    }
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

  private getHealthBgColor(): string {
    switch (this.healthStatus) {
      case HealthStatus.NORMAL:
        return '#e8f7ee'
      case HealthStatus.ATTENTION:
        return '#fff5e6'
      case HealthStatus.WARNING:
        return '#fde8e8'
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
        return '#f0f7ff'
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

  private getInsightIconColor(): string {
    if (!this.insight) return '#666666'
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
    Stack({ alignContent: Alignment.Bottom }) {
      Scroll() {
        Column({ space: 14 }) {
          this.BalanceCard()
          this.HealthStatusCard()
          if (this.insight) {
            this.InsightCard()
          }
          this.AssetSummaryCard()
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 90 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      this.AddBillButton()
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f4f5f9')
  }

  @Builder
  BalanceCard() {
    Column({ space: 8 }) {
      Row() {
        Text(this.getMonthLabel())
          .fontSize(13)
          .fontColor('rgba(255,255,255,0.75)')
        Blank()
        Text('本月结余')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.6)')
      }
      .width('100%')

      Text(this.balance >= 0 ? `¥ ${this.balance.toFixed(2)}` : `-¥ ${Math.abs(this.balance).toFixed(2)}`)
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor('#ffffff')
        .margin({ top: 4, bottom: 4 })

      Divider()
        .color('rgba(255,255,255,0.15)')
        .margin({ top: 6, bottom: 6 })

      Row() {
        Column({ space: 4 }) {
          Text('收入')
            .fontSize(11)
            .fontColor('rgba(255,255,255,0.6)')
          Text(`¥ ${this.income.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ffffff')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Divider()
          .vertical(true)
          .height(30)
          .color('rgba(255,255,255,0.15)')

        Column({ space: 4 }) {
          Text('支出')
            .fontSize(11)
            .fontColor('rgba(255,255,255,0.6)')
          Text(`¥ ${this.expense.toFixed(2)}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#ffffff')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 22, right: 22, top: 20, bottom: 20 })
    .linearGradient({
      angle: 135,
      colors: [['#2dab55', 0.0], ['#28a045', 0.5], ['#1e8a3c', 1.0]]
    })
    .borderRadius(18)
    .shadow({
      radius: 16,
      color: 'rgba(45, 171, 85, 0.25)',
      offsetX: 0,
      offsetY: 6
    })
  }

  @Builder
  HealthStatusCard() {
    Row({ space: 10 }) {
      Text(this.getHealthIcon())
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getHealthColor())
        .backgroundColor(this.getHealthBgColor())
        .width(26)
        .height(26)
        .textAlign(TextAlign.Center)
        .borderRadius(13)

      Text(this.getHealthLabel())
        .fontSize(13)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)

      Blank()

      Text(this.currentMonth)
        .fontSize(11)
        .fontColor('#aaaaaa')
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .backgroundColor('#f5f5f5')
        .borderRadius(10)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('#ffffff')
    .borderRadius(14)
    .shadow({
      radius: 6,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  InsightCard() {
    Column({ space: 10 }) {
      Row() {
        Text('💡')
          .fontSize(14)

        Text('智能提醒')
          .fontSize(13)
          .fontColor('#555555')
          .fontWeight(FontWeight.Medium)
          .margin({ left: 6 })

        Blank()

        Row({ space: 4 }) {
          Text(this.insight?.actionText || '查看')
            .fontSize(12)
            .fontColor(this.getInsightIconColor())
          Text('›')
            .fontSize(14)
            .fontColor(this.getInsightIconColor())
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(this.getInsightBgColor())
        .borderRadius(12)
        .onClick(() => {
          pathStack.pushPath({ name: 'BillStat' })
        })
      }
      .width('100%')

      Text(this.insight?.message || '')
        .fontSize(13)
        .fontColor('#444444')
        .lineHeight(20)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(14)
    .border({ width: 0.5, color: this.getInsightBorderColor() })
    .shadow({
      radius: 6,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  AssetSummaryCard() {
    Column({ space: 12 }) {
      Row() {
        Text('资产概况')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        Row({ space: 4 }) {
          Text('查看详情')
            .fontSize(12)
            .fontColor('#4a90d9')
          Text('›')
            .fontSize(14)
            .fontColor('#4a90d9')
        }
        .onClick(() => {
          pathStack.pushPathByName('AssetStat', undefined)
        })
      }
      .width('100%')

      Divider()
        .color('#f0f0f0')

      Row() {
        Column({ space: 6 }) {
          Text('总资产')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.assetSummary.asset.toFixed(2)}`)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#36ab60')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('净资产')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.assetSummary.net.toFixed(2)}`)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.assetSummary.net >= 0 ? '#36ab60' : '#d81e06')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('负债')
            .fontSize(11)
            .fontColor('#999999')
          Text(`¥ ${this.assetSummary.liability.toFixed(2)}`)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.assetSummary.liability > 0 ? '#d81e06' : '#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#ffffff')
    .borderRadius(14)
    .shadow({
      radius: 6,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  AddBillButton() {
    Column() {
      Row({ space: 6 }) {
        Text('+')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
        Text('记一笔')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#ffffff')
      }
      .width('70%')
      .height(50)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#36ab60')
      .borderRadius(25)
      .shadow({
        radius: 16,
        color: 'rgba(54, 171, 96, 0.4)',
        offsetX: 0,
        offsetY: 6
      })
      .onClick(() => {
        const params: BillEditParams = { mode: 'create' }
        pathStack.pushPath({ name: 'BillEdit', param: params })
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ bottom: 16 })
  }
}
