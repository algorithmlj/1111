import {
  ChartOptions, UCharts, UChartsController,
  PieSeries, ColumnSeries, HasLabelSeriesData,
  LegendOptions, XAxisOptions, YAxisOptions, YAxisOptionsData,
  Extra, PieExtra, ColumnExtra
} from '@ibestservices/ucharts'
import { BillModel } from '../models/BillModel'
import { BillTypeKind } from '../models/BillTypeModel'
import { BillStore } from '../viewmodels/BillStore'

@Builder
export function BillTypeStatBuilder() {
  BillTypeStat()
}

@Component
struct BillTypeStat {
  // 饼图控制器
  @State pieChart: UChartsController = new UChartsController()
  // 柱状图控制器
  @State barChart: UChartsController = new UChartsController()
  // 当前选中的类型
  @State currentType: BillTypeKind | 'all' = 'all'
  // 当前月份
  @State currentMonth: string = ''
  // 类型统计数据
  @State typeStats: TypeStatItem[] = []
  // 饼图是否就绪
  private pieReady: boolean = false
  // 柱状图是否就绪
  private barReady: boolean = false

  aboutToAppear(): void {
    const now = new Date()
    const y = now.getFullYear()
    const m = (now.getMonth() + 1).toString().padStart(2, '0')
    this.currentMonth = `${y}-${m}`
    this.loadData()
  }

  async loadData(): Promise<void> {
    const bills: BillModel[] = await BillStore.list(this.currentMonth, 'all')

    // 按类型名称分组统计
    const typeMap: Map<string, TypeStatItem> = new Map()
    for (const bill of bills) {
      const key = bill.tname
      let item = typeMap.get(key)
      if (item === undefined) {
        item = { name: key, count: 0, money: 0, type: bill.type }
        typeMap.set(key, item)
      }
      item.count += 1
      item.money += bill.money
    }

    // 转为数组并排序
    const stats: TypeStatItem[] = []
    typeMap.forEach((v: TypeStatItem) => {
      stats.push(v)
    })
    stats.sort((a: TypeStatItem, b: TypeStatItem): number => b.count - a.count)
    this.typeStats = stats

    // 根据当前筛选过滤
    let filteredStats = stats
    if (this.currentType !== 'all') {
      filteredStats = stats.filter((item: TypeStatItem) => item.type === this.currentType)
    }

    this.updateCharts(filteredStats)
  }

  updateCharts(stats: TypeStatItem[]): void {
    if (stats.length === 0) {
      return
    }

    // 饼图：各类型账单数量占比
    const pieData: HasLabelSeriesData[] = []
    for (const item of stats) {
      const d: HasLabelSeriesData = { name: item.name, value: item.count }
      pieData.push(d)
    }

    const pieSeries: PieSeries = { data: pieData }
    const pieLegend: Partial<LegendOptions> = { show: true, position: 'bottom' }
    const pieExtraDetail: Partial<PieExtra> = {
      activeOpacity: 0.5,
      activeRadius: 10,
      offsetAngle: 0,
      labelWidth: 15,
      border: true,
      borderWidth: 2,
      borderColor: '#FFFFFF'
    }
    const pieExtra: Extra = { pie: pieExtraDetail }

    const pieOpts: Partial<ChartOptions> = {
      type: 'pie',
      series: [pieSeries],
      padding: [5, 5, 5, 5],
      dataLabel: true,
      legend: pieLegend,
      extra: pieExtra
    }

    // 柱状图：各类型账单金额
    const categories: string[] = []
    const moneyData: number[] = []
    for (const item of stats) {
      categories.push(item.name)
      moneyData.push(Math.round(item.money * 100) / 100)
    }

    const colSeries: ColumnSeries = { name: '金额', data: moneyData }
    const colXAxis: Partial<XAxisOptions> = { disableGrid: true }
    const yAxisItem: Partial<YAxisOptionsData> = { min: 0 }
    const colYAxis: Partial<YAxisOptions> = { data: [yAxisItem] }
    const colLegend: Partial<LegendOptions> = { show: false }
    const colExtraDetail: Partial<ColumnExtra> = {
      type: 'group',
      width: 25,
      activeBgColor: '#000000',
      activeBgOpacity: 0.08,
      barBorderRadius: [4, 4, 0, 0]
    }
    const colExtra: Extra = { column: colExtraDetail }

    const barOpts: Partial<ChartOptions> = {
      type: 'column',
      categories: categories,
      series: [colSeries],
      padding: [15, 15, 0, 5],
      dataLabel: true,
      xAxis: colXAxis,
      yAxis: colYAxis,
      legend: colLegend,
      extra: colExtra
    }

    if (this.pieReady) {
      this.pieChart.updateData(pieOpts)
    }
    if (this.barReady) {
      this.barChart.updateData(barOpts)
    }
  }

  // 切换月份
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

        // 类型切换
        Row({ space: 12 }) {
          this.TypeTab('全部', 'all')
          this.TypeTab('支出', 'expense')
          this.TypeTab('收入', 'income')
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 8 })

        Scroll() {
          Column({ space: 16 }) {
            // 饼图：账单类型数量占比
            Column() {
              Text('账单类型数量占比')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              UCharts({
                controller: this.pieChart,
                contentWidth: '100%',
                contentHeight: 280,
                onReady: () => {
                  this.pieReady = true
                  this.loadData()
                }
              })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(12)

            // 柱状图：各类型账单金额
            Column() {
              Text('各类型账单金额')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              UCharts({
                controller: this.barChart,
                contentWidth: '100%',
                contentHeight: 280,
                onReady: () => {
                  this.barReady = true
                  this.loadData()
                }
              })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(12)

            // 明细列表
            Column() {
              Text('分类明细')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              ForEach(this.typeStats.filter((item: TypeStatItem) =>
                this.currentType === 'all' || item.type === this.currentType
              ), (item: TypeStatItem) => {
                Row() {
                  Text(item.name)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                  Text(`${item.count}笔`)
                    .fontSize(13)
                    .fontColor('#999999')
                    .margin({ right: 12 })
                  Text(`¥${item.money.toFixed(2)}`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(item.type === 'income' ? '#36ab60' : '#d81e06')
                }
                .width('100%')
                .padding({ top: 10, bottom: 10 })
                .border({ width: { bottom: 0.5 }, color: '#F0F0F0' })
              }, (item: TypeStatItem) => item.name)
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
    .title('账单类型统计')
    .onShown(() => {
      this.loadData()
    })
  }

  @Builder
  TypeTab(label: string, type: BillTypeKind | 'all') {
    Text(label)
      .fontSize(13)
      .fontColor(this.currentType === type ? Color.White : '#666666')
      .backgroundColor(this.currentType === type ? '#d81e06' : '#F0F0F0')
      .borderRadius(15)
      .padding({ left: 16, right: 16, top: 6, bottom: 6 })
      .onClick(() => {
        this.currentType = type
        this.loadData()
      })
  }
}

interface TypeStatItem {
  name: string
  count: number
  money: number
  type: string
}
