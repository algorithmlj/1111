import {
  ChartOptions, UCharts, UChartsController,
  RingSeries, ColumnSeries, HasLabelSeriesData,
  TitleOptions, LegendOptions, XAxisOptions, YAxisOptions, YAxisOptionsData,
  Extra, RingExtra, ColumnExtra
} from '@ibestservices/ucharts'
import { AssetModel, getAssetColor } from '../models/AssetModel'
import { AssetStore } from '../viewmodels/AssetStore'
import { AssetSummary } from '../models/AssetModel'

@Builder
export function AssetStatBuilder() {
  AssetStat()
}

@Component
struct AssetStat {
  // 饼图：资产分布
  @State assetPieChart: UChartsController = new UChartsController()
  // 柱状图：各资产金额
  @State assetBarChart: UChartsController = new UChartsController()
  // 资产汇总
  @State summary: AssetSummary = new AssetSummary()
  // 资产列表
  @State assetList: AssetModel[] = []
  // 图表就绪
  private pieReady: boolean = false
  private barReady: boolean = false

  aboutToAppear(): void {
    this.loadData()
  }

  async loadData(): Promise<void> {
    this.assetList = await AssetStore.list()
    this.summary = await AssetStore.summary()
    this.updateCharts()
  }

  updateCharts(): void {
    if (this.assetList.length === 0) {
      return
    }

    // 按资产类型分组汇总
    const typeMap: Map<string, AssetTypeStatItem> = new Map()
    for (const asset of this.assetList) {
      const key = asset.type
      let item = typeMap.get(key)
      if (item === undefined) {
        item = { name: key, totalMoney: 0, count: 0, color: getAssetColor(asset.type) }
        typeMap.set(key, item)
      }
      item.totalMoney += asset.money
      item.count += 1
    }

    // 饼图数据（取绝对值，因为负债为负数）
    const pieData: HasLabelSeriesData[] = []
    const pieColors: string[] = []
    typeMap.forEach((item: AssetTypeStatItem) => {
      const d: HasLabelSeriesData = {
        name: item.name,
        value: Math.abs(Math.round(item.totalMoney * 100) / 100)
      }
      pieData.push(d)
      pieColors.push(item.color)
    })

    const ringSeries: RingSeries = { data: pieData }
    const ringTitle: Partial<TitleOptions> = { value: '净资产', fontSize: 14, color: '#666666', offsetY: -8 }
    const ringSubtitle: Partial<TitleOptions> = {
      value: `¥${this.summary.net.toFixed(2)}`,
      fontSize: 16,
      color: '#333333',
      offsetY: 10
    }
    const ringLegend: Partial<LegendOptions> = { show: true, position: 'bottom' }
    const ringExtraDetail: Partial<RingExtra> = {
      ringWidth: 30,
      centerColor: '#FFFFFF',
      activeOpacity: 0.5,
      activeRadius: 10,
      border: true,
      borderWidth: 2,
      borderColor: '#FFFFFF'
    }
    const ringExtra: Extra = { ring: ringExtraDetail }

    const pieOpts: Partial<ChartOptions> = {
      type: 'ring',
      series: [ringSeries],
      color: pieColors,
      padding: [5, 5, 5, 5],
      dataLabel: true,
      legend: ringLegend,
      title: ringTitle,
      subtitle: ringSubtitle,
      extra: ringExtra
    }

    // 柱状图：各资产具体金额
    const categories: string[] = []
    const moneyData: number[] = []
    const barColors: string[] = []
    for (const asset of this.assetList) {
      categories.push(asset.name.length > 4 ? asset.name.substring(0, 4) : asset.name)
      moneyData.push(Math.round(asset.money * 100) / 100)
      barColors.push(getAssetColor(asset.type))
    }

    const colSeries: ColumnSeries = { name: '金额', data: moneyData }
    const colXAxis: Partial<XAxisOptions> = {
      disableGrid: true,
      rotateLabel: categories.length > 5,
      rotateAngle: 45
    }
    const yAxisItem: Partial<YAxisOptionsData> = {}
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
      color: barColors,
      padding: [15, 15, 0, 5],
      dataLabel: true,
      xAxis: colXAxis,
      yAxis: colYAxis,
      legend: colLegend,
      extra: colExtra
    }

    if (this.pieReady) {
      this.assetPieChart.updateData(pieOpts)
    }
    if (this.barReady) {
      this.assetBarChart.updateData(barOpts)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 16 }) {
            // 资产汇总卡片
            Row({ space: 0 }) {
              Column() {
                Text('总资产')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.summary.asset.toFixed(2)}`)
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
                Text('总负债')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.summary.liability.toFixed(2)}`)
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
                Text('净资产')
                  .fontSize(12)
                  .fontColor('#999999')
                Text(`¥${this.summary.net.toFixed(2)}`)
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

            // 环形图：资产分布
            Column() {
              Text('资产类型分布')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              UCharts({
                controller: this.assetPieChart,
                contentWidth: '100%',
                contentHeight: 300,
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

            // 柱状图：各资产金额
            Column() {
              Text('各资产账户金额')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              UCharts({
                controller: this.assetBarChart,
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

            // 资产明细列表
            Column() {
              Text('资产明细')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 8 })

              ForEach(this.assetList, (asset: AssetModel) => {
                Row() {
                  // 类型图标
                  Column() {
                    Text(asset.icon)
                      .fontSize(14)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                  }
                  .width(32)
                  .height(32)
                  .borderRadius(16)
                  .backgroundColor(getAssetColor(asset.type))
                  .justifyContent(FlexAlign.Center)
                  .margin({ right: 10 })

                  Column() {
                    Text(asset.name)
                      .fontSize(14)
                      .fontColor('#333333')
                    Text(asset.type)
                      .fontSize(11)
                      .fontColor('#999999')
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Text(`¥${asset.money.toFixed(2)}`)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(asset.money >= 0 ? '#36ab60' : '#d81e06')
                }
                .width('100%')
                .padding({ top: 10, bottom: 10 })
                .border({ width: { bottom: 0.5 }, color: '#F0F0F0' })
              }, (asset: AssetModel) => asset.id)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(12)
          }
          .padding({ left: 12, right: 12, top: 12, bottom: 20 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#F5F5F5')
    }
    .title('资产统计')
    .onShown(() => {
      this.loadData()
    })
  }
}

interface AssetTypeStatItem {
  name: string
  totalMoney: number
  count: number
  color: string
}
