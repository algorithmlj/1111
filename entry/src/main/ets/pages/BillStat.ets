import {
  ChartOptions, UCharts, UChartsController,
  ColumnSeries, LineSeries,
  LegendOptions, XAxisOptions, YAxisOptions, YAxisOptionsData,
  Extra, ColumnExtra, LineExtra
} from '@ibestservices/ucharts'
import { BillModel } from '../models/BillModel'
import { BillStore } from '../viewmodels/BillStore'

@Builder
export function BillStatBuilder() {
  BillStat()
}

@Component
struct BillStat {
  // 周柱状图
  @State weekChart: UChartsController = new UChartsController()
  // 月折线图
  @State monthChart: UChartsController = new UChartsController()
  // 当前月份
  @State currentMonth: string = ''
  // 月度汇总
  @State monthIncome: number = 0
  @State monthExpense: number = 0
  // 图表就绪状态
  private weekReady: boolean = false
  private monthReady: boolean = false

  aboutToAppear(): void {
    const now = new Date()
    const y = now.getFullYear()
    const m = (now.getMonth() + 1).toString().padStart(2, '0')
    this.currentMonth = `${y}-${m}`
    this.loadData()
  }

  async loadData(): Promise<void> {
    const bills: BillModel[] = await BillStore.list(this.currentMonth, 'all')

    // 月度汇总
    let income = 0
    let expense = 0
    for (const bill of bills) {
      if (bill.type === 'income') {
        income += bill.money
      } else {
        expense += bill.money
      }
    }
    this.monthIncome = Math.round(income * 100) / 100
    this.monthExpense = Math.round(expense * 100) / 100

    // 按天统计
    const dailyIncome: Map<string, number> = new Map()
    const dailyExpense: Map<string, number> = new Map()
    for (const bill of bills) {
      if (bill.type === 'income') {
        const prev = dailyIncome.get(bill.ctime) ?? 0
        dailyIncome.set(bill.ctime, prev + bill.money)
      } else {
        const prev = dailyExpense.get(bill.ctime) ?? 0
        dailyExpense.set(bill.ctime, prev + bill.money)
      }
    }

    // 生成当月所有日期
    const parts = this.currentMonth.split('-')
    const year = Number.parseInt(parts[0])
    const month = Number.parseInt(parts[1])
    const daysInMonth = new Date(year, month, 0).getDate()

    const allDays: string[] = []
    const incomeByDay: number[] = []
    const expenseByDay: number[] = []
    for (let d = 1; d <= daysInMonth; d++) {
      const dayStr = `${this.currentMonth}-${d.toString().padStart(2, '0')}`
      allDays.push(d.toString())
      incomeByDay.push(Math.round((dailyIncome.get(dayStr) ?? 0) * 100) / 100)
      expenseByDay.push(Math.round((dailyExpense.get(dayStr) ?? 0) * 100) / 100)
    }

    // 周统计（最近7天）
    this.updateWeekChart(bills)
    // 月趋势折线图
    this.updateMonthChart(allDays, incomeByDay, expenseByDay)
  }

  updateWeekChart(bills: BillModel[]): void {
    const now = new Date()
    const weekDays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    const categories: string[] = []
    const incomeData: number[] = []
    const expenseData: number[] = []

    // 近7天
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
      const dateStr =
        `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`
      const dayLabel = `周${weekDays[d.getDay()]}`
      categories.push(dayLabel)

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
      width: 15,
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

    if (this.weekReady) {
      this.weekChart.updateData(opts)
    }
  }

  updateMonthChart(days: string[], incomeByDay: number[], expenseByDay: number[]): void {
    // 如果天数过多，按每5天取一个标签
    const labelInterval = days.length > 15 ? 5 : 1
    const displayCategories: string[] = []
    for (let i = 0; i < days.length; i++) {
      if (i % labelInterval === 0 || i === days.length - 1) {
        displayCategories.push(days[i])
      } else {
        displayCategories.push('')
      }
    }

    const lineIncome: LineSeries = { name: '收入', data: incomeByDay, color: '#36ab60' }
    const lineExpense: LineSeries = { name: '支出', data: expenseByDay, color: '#d81e06' }
    const lineXAxis: Partial<XAxisOptions> = { disableGrid: false, gridType: 'dash' }
    const yAxisItem: Partial<YAxisOptionsData> = { min: 0 }
    const lineYAxis: Partial<YAxisOptions> = { data: [yAxisItem] }
    const lineLegend: Partial<LegendOptions> = { show: true, position: 'bottom' }
    const lineExtraDetail: Partial<LineExtra> = {
      type: 'curve',
      width: 2,
      activeType: 'hollow'
    }
    const lineExtra: Extra = { line: lineExtraDetail }

    const opts: Partial<ChartOptions> = {
      type: 'line',
      categories: displayCategories,
      series: [lineIncome, lineExpense],
      padding: [15, 10, 0, 15],
      dataLabel: false,
      dataPointShape: false,
      xAxis: lineXAxis,
      yAxis: lineYAxis,
      legend: lineLegend,
      extra: lineExtra
    }

    if (this.monthReady) {
      this.monthChart.updateData(opts)
    }
  }

  changeMonth(offset: number): void {
    const parts = this.currentMonth.split('-')
    let y = Number.parseInt(parts[0])
    let m = Number.parseInt(parts[1]) + offset
    if (m > 12) {
      m = 1; y += 1
    } else if (m < 1) {
      m = 12; y -= 1
    }
    this.currentMonth = `${y}-${m.toString().padStart(2, '0')}`
    this.loadData()
  }

  build() {
    NavDestination() {
      Column() {
        // 月份选择器
        Row() {
          Button('<')
            .type(ButtonType.Circle)
            .width(32).height(32)
            .fontSize(16)
            .backgroundColor('#F0F0F0')
            .fontColor('#333333')
            .onClick(() => this.changeMonth(-1))

          Text(this.currentMonth)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 16, right: 16 })

          Button('>')
            .type(ButtonType.Circle)
            .width(32).height(32)
            .fontSize(16)
            .backgroundColor('#F0F0F0')
            .fontColor('#333333')
            .onClick(() => this.changeMonth(1))
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ top: 12, bottom: 8 })

        Scroll() {
          Column({ space: 16 }) {
            // 月度收支汇总卡片
            Row({ space: 0 }) {
              Column() {
                Text('本月收入')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.monthIncome.toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#36ab60')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Divider()
                .vertical(true)
                .height(40)
                .color('#E0E0E0')

              Column() {
                Text('本月支出')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.monthExpense.toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#d81e06')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Divider()
                .vertical(true)
                .height(40)
                .color('#E0E0E0')

              Column() {
                Text('本月结余')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${(this.monthIncome - this.monthExpense).toFixed(2)}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)

            // 本周收支柱状图
            Column() {
              Text('本周收支')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              UCharts({
                controller: this.weekChart,
                contentWidth: '100%',
                contentHeight: 260,
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

            // 月度趋势折线图
            Column() {
              Text('本月收支趋势')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              UCharts({
                controller: this.monthChart,
                contentWidth: '100%',
                contentHeight: 260,
                onReady: () => {
                  this.monthReady = true
                  this.loadData()
                }
              })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(12)
          }
          .padding({ left: 12, right: 12, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('账单统计')
    .onShown(() => {
      this.loadData()
    })
  }
}
