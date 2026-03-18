import {
  ChartOptions, UCharts, UChartsController,
  RingSeries, ColumnSeries, HasLabelSeriesData,
  TitleOptions, LegendOptions, XAxisOptions, YAxisOptions, YAxisOptionsData,
  Extra, RingExtra, ColumnExtra
} from '@ibestservices/ucharts'
import { BillModel, BillSummary } from '../models/BillModel'
import { AssetSummary } from '../models/AssetModel'
import { BillStore } from '../viewmodels/BillStore'
import { AssetStore } from '../viewmodels/AssetStore'
import { pathStack } from '../commons/SystemConfig'

@Component
export struct Statistic {
  // 父组件传入的当前 Tab 索引，用于监听切换
  @Prop @Watch('onTabChanged') currentTabIndex: number = 0
  // 本月收支饼图
  @State overviewChart: UChartsController = new UChartsController()
  // 本周柱状图
  @State weekChart: UChartsController = new UChartsController()
  // 当前月份
  @State currentMonth: string = ''
  // 汇总数据
  @State monthIncome: number = 0
  @State monthExpense: number = 0
  @State assetSummary: AssetSummary = new AssetSummary()
  // 图表就绪
  private overviewReady: boolean = false
  private weekReady: boolean = false

  aboutToAppear(): void {
    const now = new Date()
    const y = now.getFullYear()
    const m = (now.getMonth() + 1).toString().padStart(2, '0')
    this.currentMonth = `${y}-${m}`
  }

  /**
   * Tab 切换时触发，当切换到统计 Tab（index=4）时刷新数据
   */
  onTabChanged(): void {
    if (this.currentTabIndex === 4) {
      this.loadData()
    }
  }

  async loadData(): Promise<void> {
    // 加载月度账单
    const summary: BillSummary = await BillStore.sumByMonth(this.currentMonth)
    this.monthIncome = Math.round(summary.income * 100) / 100
    this.monthExpense = Math.round(summary.expense * 100) / 100

    // 加载资产汇总
    this.assetSummary = await AssetStore.summary()

    // 更新收支概览饼图
    this.updateOverviewChart()

    // 更新本周柱状图
    const bills: BillModel[] = await BillStore.list(this.currentMonth, 'all')
    this.updateWeekChart(bills)
  }

  updateOverviewChart(): void {
    if (!this.overviewReady) {
      return
    }

    const pieData: HasLabelSeriesData[] = []
    if (this.monthIncome > 0) {
      const incomeItem: HasLabelSeriesData = { name: '收入', value: this.monthIncome }
      pieData.push(incomeItem)
    }
    if (this.monthExpense > 0) {
      const expenseItem: HasLabelSeriesData = { name: '支出', value: this.monthExpense }
      pieData.push(expenseItem)
    }

    if (pieData.length === 0) {
      const emptyItem: HasLabelSeriesData = { name: '暂无数据', value: 0 }
      pieData.push(emptyItem)
    }

    const ringSeries: RingSeries = { data: pieData }
    const ringTitle: Partial<TitleOptions> = { value: '结余', fontSize: 12, color: '#999999', offsetY: -8 }
    const ringSubtitle: Partial<TitleOptions> = {
      value: `¥${(this.monthIncome - this.monthExpense).toFixed(2)}`,
      fontSize: 14,
      color: '#333333',
      offsetY: 8
    }
    const ringLegend: Partial<LegendOptions> = { show: true, position: 'bottom' }
    const ringExtraDetail: Partial<RingExtra> = {
      ringWidth: 25,
      centerColor: '#FFFFFF',
      activeOpacity: 0.5,
      activeRadius: 8,
      border: true,
      borderWidth: 2,
      borderColor: '#FFFFFF'
    }
    const ringExtra: Extra = { ring: ringExtraDetail }

    const opts: Partial<ChartOptions> = {
      type: 'ring',
      series: [ringSeries],
      color: ['#36ab60', '#d81e06', '#cccccc'],
      padding: [5, 5, 5, 5],
      dataLabel: true,
      legend: ringLegend,
      title: ringTitle,
      subtitle: ringSubtitle,
      extra: ringExtra
    }
    this.overviewChart.updateData(opts)
  }

  updateWeekChart(bills: BillModel[]): void {
    if (!this.weekReady) {
      return
    }

    const now = new Date()
    const weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    const categories: string[] = []
    const incomeData: number[] = []
    const expenseData: number[] = []

    for (let i = 6; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
      const dateStr =
        `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`
      categories.push(`周${weekDays[d.getDay()]}`)

      let dayIncome = 0
      let dayExpense = 0
      for (const bill of bills) {
        if (bill.ctime === dateStr) {
          if (bill.type === 'income') {
            dayIncome += bill.money
          } else {
            dayExpense += bill.money
          }
        }
      }
      incomeData.push(Math.round(dayIncome * 100) / 100)
      expenseData.push(Math.round(dayExpense * 100) / 100)
    }

    const incomeSeries: ColumnSeries = { name: '收入', data: incomeData, color: '#36ab60' }
    const expenseSeries: ColumnSeries = { name: '支出', data: expenseData, color: '#d81e06' }
    const colXAxis: Partial<XAxisOptions> = { disableGrid: true }
    const yAxisItem: Partial<YAxisOptionsData> = { min: 0 }
    const colYAxis: Partial<YAxisOptions> = { data: [yAxisItem] }
    const colLegend: Partial<LegendOptions> = { show: true, position: 'bottom' }
    const colExtraDetail: Partial<ColumnExtra> = {
      type: 'group',
      width: 12,
      activeBgColor: '#000000',
      activeBgOpacity: 0.08,
      barBorderRadius: [3, 3, 0, 0]
    }
    const colExtra: Extra = { column: colExtraDetail }

    const opts: Partial<ChartOptions> = {
      type: 'column',
      categories: categories,
      series: [incomeSeries, expenseSeries],
      padding: [15, 15, 0, 5],
      dataLabel: false,
      xAxis: colXAxis,
      yAxis: colYAxis,
      legend: colLegend,
      extra: colExtra
    }
    this.weekChart.updateData(opts)
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          // ===== 资产概览卡片 =====
          Column({ space: 6 }) {
            Text('资产概览')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Row({ space: 0 }) {
              Column() {
                Text('总资产')
                  .fontSize(11)
                  .fontColor('#999999')
                Text(`¥${this.assetSummary.asset.toFixed(2)}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#36ab60')
                  .margin({ top: 2 })
              }
              .layoutWeight(1)

              Column() {
                Text('总负债')
                  .fontSize(11)
                  .fontColor('#999999')
                Text(`¥${this.assetSummary.liability.toFixed(2)}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#d81e06')
                  .margin({ top: 2 })
              }
              .layoutWeight(1)

              Column() {
                Text('净资产')
                  .fontSize(11)
                  .fontColor('#999999')
                Text(`¥${this.assetSummary.net.toFixed(2)}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)

          // ===== 本月收支概览（环形图） =====
          Column() {
            Row() {
              Text(`${this.currentMonth} 收支概览`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Blank()
              Text(`收入 ¥${this.monthIncome.toFixed(2)} | 支出 ¥${this.monthExpense.toFixed(2)}`)
                .fontSize(11)
                .fontColor('#999999')
            }
            .width('100%')
            .margin({ bottom: 4 })

            UCharts({
              controller: this.overviewChart,
              contentWidth: '100%',
              contentHeight: 220,
              onReady: () => {
                this.overviewReady = true
                this.loadData()
              }
            })
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)

          // ===== 本周收支柱状图 =====
          Column() {
            Text('本周收支')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 4 })

            UCharts({
              controller: this.weekChart,
              contentWidth: '100%',
              contentHeight: 200,
              onReady: () => {
                this.weekReady = true
                this.loadData()
              }
            })
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)

          // ===== 快捷导航入口 =====
          Column({ space: 0 }) {
            Text('详细统计')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 8 })

            this.NavEntry('账单统计', '查看每月/每周收支趋势', '#4A90D9', 'BillStat')
            this.NavEntry('账单类型统计', '查看各类型账单数量与金额', '#FF6B35', 'BillTypeStat')
            this.NavEntry('资产统计', '查看资产分布与各账户余额', '#36AB60', 'AssetStat')
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Color.White)
          .borderRadius(12)
        }
        .padding({ left: 12, right: 12, top: 8, bottom: 20 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  NavEntry(title: string, desc: string, color: string, routeName: string) {
    Row() {
      // 左侧色块
      Column()
        .width(4)
        .height(36)
        .borderRadius(2)
        .backgroundColor(color)
        .margin({ right: 12 })

      Column() {
        Text(title)
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        Text(desc)
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(16)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 0.5 }, color: '#F0F0F0' })
    .onClick(() => {
      pathStack.pushPathByName(routeName, undefined)
    })
  }
}
