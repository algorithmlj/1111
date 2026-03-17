import { pathStack } from '../commons/SystemConfig'
import {
  AssetDetailParams,
  AssetEditParams,
  AssetModel,
  AssetSummary,
  getAssetColor
} from '../commons/AssetModel'
import { AssetStore } from '../commons/AssetStore'

@Component
export struct Assets {
  @State private assets: AssetModel[] = []
  @State private summary: AssetSummary = new AssetSummary()
  @State private showMoney: boolean = true

  aboutToAppear() {
    this.refreshData()
  }

  private async refreshData(): Promise<void> {
    this.assets = await AssetStore.list()
    this.summary = await AssetStore.summary()
  }

  private formatMoney(value: number): string {
    if (!this.showMoney) {
      return '****'
    }
    return value.toFixed(2)
  }

  build() {
    Column({ space: 0 }) {
      // ═══ 净资产卡片（通栏贴顶，和 Bill 页面结构一致）═══
      Stack() {
        // 渐变背景
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 135,
            colors: [['#e8f5e9', 0.0], ['#f1f8e9', 0.5], ['#ffffff', 1.0]]
          })

        // 右上角装饰
        Text('🌿')
          .fontSize(40)
          .opacity(0.3)
          .position({ right: 16, top: 12 })

        // 内容
        Column({ space: 0 }) {
          // 净资产标签 + 眼睛图标
          Row({ space: 8 }) {
            Text('净资产')
              .fontSize(13)
              .fontColor('#666666')

            Text(this.showMoney ? '👁' : '🙈')
              .fontSize(16)
              .onClick(() => {
                this.showMoney = !this.showMoney
              })
          }
          .width('100%')

          // 净资产金额
          Text(this.showMoney ? this.summary.net.toFixed(2) : '****')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 8, bottom: 16 })
            .width('100%')

          // 资产 / 负债
          Row() {
            Row({ space: 6 }) {
              Text('资产')
                .fontSize(12)
                .fontColor('#999999')
              Text(this.formatMoney(this.summary.asset))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }

            Row()
              .width(1)
              .height(14)
              .backgroundColor('#e0e0e0')
              .margin({ left: 20, right: 20 })

            Row({ space: 6 }) {
              Text('负债')
                .fontSize(12)
                .fontColor('#999999')
              Text(this.formatMoney(this.summary.liability))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
          }
          .width('100%')
        }
        .padding({ left: 20, right: 20, top: 20, bottom: 20 })
      }
      .width('100%')
      .height(150)
      .shadow({
        radius: 8,
        color: 'rgba(0, 0, 0, 0.05)',
        offsetX: 0,
        offsetY: 2
      })

      // ═══ 添加按钮 + 列表区域 ═══
      Column({ space: 0 }) {
        // 添加资产按钮
        Row() {
          Text('+ 添加资产')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#666666')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f0f0f3')
        .borderRadius(14)
        .margin({ left: 16, right: 16, top: 12, bottom: 12 })
        .onClick(() => {
          const params: AssetEditParams = { mode: 'create' }
          pathStack.pushPath({ name: 'AssetEdit', param: params })
        })

        // 资产列表 / 空状态
        if (this.assets.length === 0) {
          Column({ space: 10 }) {
            Text('📋')
              .fontSize(40)
              .opacity(0.4)
            Text('暂无记录')
              .fontSize(14)
              .fontColor('#bbbbbb')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 8 }) {
            ForEach(this.assets, (item: AssetModel) => {
              ListItem() {
                Row() {
                  // 图标
                  Row() {
                    Text(item.icon)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#ffffff')
                  }
                  .width(42)
                  .height(42)
                  .backgroundColor(getAssetColor(item.type))
                  .borderRadius(21)
                  .justifyContent(FlexAlign.Center)
                  .margin({ right: 12 })

                  // 名称 + 类型
                  Column({ space: 4 }) {
                    Text(item.name)
                      .fontSize(15)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)
                    Text(item.type)
                      .fontSize(11)
                      .fontColor('#999999')
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  // 金额
                  Text(this.showMoney
                    ? `${item.money >= 0 ? '' : '-'}¥ ${Math.abs(item.money).toFixed(2)}`
                    : '¥ ****')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(item.money >= 0 ? '#333333' : '#d81e06')
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
                  const params: AssetDetailParams = { assetId: item.id }
                  pathStack.pushPath({ name: 'AssetDetail', param: params })
                })
              }
            }, (item: AssetModel): string => item.id)
          }
          .padding({ left: 16, right: 16, bottom: 24 })
          .layoutWeight(1)
          .width('100%')
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f8')
    .onAppear(() => {
      this.refreshData()
    })
  }
}
