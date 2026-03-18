import { pathStack } from '../commons/SystemConfig'
import {
  AssetEditParams,
  AssetModel,
  AssetType,
  ASSET_TYPE_LIST,
  getAssetColor,
  getAssetIcon
} from '../models/AssetModel'
import { AssetStore } from '../viewmodels/AssetStore'

@Builder
export function AssetEditBuilder(name: string) {
  AssetEdit()
}

@Component
export struct AssetEdit {
  @State private mode: 'create' | 'edit' = 'create'
  @State private editId: string = ''
  @State private selectedType: AssetType = '现金'
  @State private name: string = ''
  @State private money: string = ''
  @State private info: string = ''
  @State private errorText: string = ''

  private async initFromParams(params: AssetEditParams): Promise<void> {
    this.mode = params.mode
    if (this.mode === 'edit' && typeof params.assetId === 'string') {
      this.editId = params.assetId
      const asset: AssetModel | undefined = await AssetStore.findById(this.editId)
      if (asset !== undefined) {
        this.selectedType = asset.type
        this.name = asset.name
        this.money = asset.money.toString()
        this.info = asset.info
      }
    }
  }

  private async submit(): Promise<void> {
    if (this.name.length === 0) {
      this.errorText = '请输入资产名称'
      return
    }
    const moneyNum: number = parseFloat(this.money)
    if (isNaN(moneyNum)) {
      this.errorText = '请输入正确的金额'
      return
    }

    if (this.mode === 'create') {
      const now: string = Date.now().toString(36)
      const random: string = Math.floor(Math.random() * 10000).toString(36)
      const asset: AssetModel = {
        id: `asset_${now}_${random}`,
        type: this.selectedType,
        icon: getAssetIcon(this.selectedType),
        name: this.name,
        money: moneyNum,
        info: this.info
      }
      await AssetStore.create(asset)
    } else {
      const asset: AssetModel = {
        id: this.editId,
        type: this.selectedType,
        icon: getAssetIcon(this.selectedType),
        name: this.name,
        money: moneyNum,
        info: this.info
      }
      await AssetStore.update(asset)
    }
    pathStack.pop()
  }

  build() {
    NavDestination() {
      Column({ space: 0 }) {
        Scroll() {
          Column({ space: 20 }) {

            // 资产类型选择
            Column({ space: 10 }) {
              Text('资产类型')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(ASSET_TYPE_LIST, (t: AssetType) => {
                  Text(t)
                    .fontSize(13)
                    .fontColor(this.selectedType === t ? '#ffffff' : getAssetColor(t))
                    .backgroundColor(this.selectedType === t ? getAssetColor(t) : '#f5f5f8')
                    .borderRadius(16)
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => {
                      this.selectedType = t
                      this.errorText = ''
                    })
                }, (t: AssetType): string => t)
              }
              .width('100%')
            }
            .width('100%')

            // 资产名称
            Column({ space: 10 }) {
              Text('资产名称')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              TextInput({ placeholder: '例如：工商银行卡、现金钱包', text: this.name })
                .onChange((value: string) => {
                  this.name = value
                  this.errorText = ''
                })
                .height(48)
                .borderRadius(12)
                .backgroundColor('#f8f8fa')
                .width('100%')
            }
            .width('100%')

            // 金额输入
            Column({ space: 10 }) {
              Text('金额')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              TextInput({ placeholder: '请输入金额（负数表示负债）', text: this.money })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.money = value
                  this.errorText = ''
                })
                .height(48)
                .borderRadius(12)
                .backgroundColor('#f8f8fa')
                .width('100%')
            }
            .width('100%')

            // 备注
            Column({ space: 10 }) {
              Text('备注')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              TextInput({ placeholder: '选填备注信息', text: this.info })
                .onChange((value: string) => {
                  this.info = value
                })
                .height(48)
                .borderRadius(12)
                .backgroundColor('#f8f8fa')
                .width('100%')
            }
            .width('100%')

            // 错误提示
            if (this.errorText.length > 0) {
              Text(this.errorText)
                .fontSize(12)
                .fontColor('#d81e06')
                .width('100%')
                .padding({ left: 4 })
            }
          }
          .padding(20)
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(16)
        .margin(16)
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.06)',
          offsetX: 0,
          offsetY: 2
        })

        // 底部按钮
        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(46)
            .type(ButtonType.Capsule)
            .backgroundColor('#f2f2f5')
            .fontColor('#666666')
            .fontSize(15)
            .onClick(() => {
              pathStack.pop()
            })

          Button(this.mode === 'create' ? '确认添加' : '保存修改')
            .layoutWeight(1)
            .height(46)
            .type(ButtonType.Capsule)
            .backgroundColor(getAssetColor(this.selectedType))
            .fontColor('#ffffff')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .onClick(async () => {
              await this.submit()
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .height('100%')
      .width('100%')
      .backgroundColor('#f5f5f8')
    }
    .title(this.mode === 'create' ? '新增资产' : '修改资产')
    .onReady(async (context: NavDestinationContext) => {
      const params: AssetEditParams | undefined = context.pathInfo?.param as AssetEditParams | undefined
      if (params !== undefined) {
        await this.initFromParams(params)
      } else {
        const defaultParams: AssetEditParams = { mode: 'create' }
        await this.initFromParams(defaultParams)
      }
    })
  }
}
