import { pathStack } from '../commons/SystemConfig'
import { BillTypeEditParams, BillTypeKind, BillTypeModel } from '../commons/BillTypeModel'
import { BillTypeStore } from '../commons/BillTypeStore'

@Builder
export function BillTypeBuilder(name: string) {
  BillType()
}

@Component
export struct BillType {
  @State private currentType: BillTypeKind = 'expense'
  @State private billTypes: BillTypeModel[] = []

  aboutToAppear() {
    this.refreshList()
  }

  private refreshList() {
    this.billTypes = BillTypeStore.listByType(this.currentType)
  }

  @Builder
  private typeTab(label: string, value: BillTypeKind) {
    Button(label)
      .type(ButtonType.Capsule)
      .backgroundColor(this.currentType === value ? '#d81e06' : '#f3f3f3')
      .fontColor(this.currentType === value ? '#ffffff' : '#333333')
      .onClick(() => {
        this.currentType = value
        this.refreshList()
      })
  }

  private deleteType(id: string) {
    BillTypeStore.remove(id)
    this.refreshList()
  }

  build() {
    NavDestination() {
      Column({ space: 14 }) {
        Row({ space: 10 }) {
          this.typeTab('支出类型', 'expense')
          this.typeTab('收入类型', 'income')
          Blank()
          Button('新增')
            .type(ButtonType.Capsule)
            .backgroundColor('#d81e06')
            .onClick(() => {
              const params: BillTypeEditParams = {
                mode: 'create',
                type: this.currentType
              }
              pathStack.pushPath({
                name: 'BillTypeEdit',
                param: params
              })
            })
        }
        .width('100%')

        if (this.billTypes.length === 0) {
          Column() {
            Text('暂无账单类型，点击右上角新增')
              .fontSize(14)
              .fontColor('#999999')
          }
          .height('70%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 8 }) {
            ForEach(this.billTypes, (item: BillTypeModel) => {
              ListItem() {
                Row() {
                  Text(item.name)
                    .fontSize(16)
                    .fontColor('#222222')
                  Blank()
                  Row({ space: 8 }) {
                    Button('编辑')
                      .type(ButtonType.Capsule)
                      .height(28)
                      .fontSize(12)
                      .backgroundColor('#fff3f1')
                      .fontColor('#d81e06')
                      .onClick(() => {
                        const params: BillTypeEditParams = {
                          mode: 'edit',
                          id: item.id,
                          type: item.type
                        }
                        pathStack.pushPath({
                          name: 'BillTypeEdit',
                          param: params
                        })
                      })
                    Button('删除')
                      .type(ButtonType.Capsule)
                      .height(28)
                      .fontSize(12)
                      .backgroundColor('#f5f5f5')
                      .fontColor('#666666')
                      .onClick(() => {
                        this.deleteType(item.id)
                      })
                  }
                }
                .padding({ left: 12, right: 12, top: 14, bottom: 14 })
                .width('100%')
                .backgroundColor('#ffffff')
                .borderRadius(10)
              }
            }, (item: BillTypeModel): string => item.id)
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .padding(16)
      .height('100%')
      .width('100%')
      .backgroundColor('#fafafa')
      .onAppear(() => {
        this.refreshList()
      })
    }
    .title('账单类型')
  }
}
