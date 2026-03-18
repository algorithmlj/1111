import { pathStack } from '../commons/SystemConfig'
import { BillTypeEditParams, BillTypeKind, BillTypeModel } from '../models/BillTypeModel'
import { BillTypeStore } from '../viewmodels/BillTypeStore'

@Builder
export function BillTypeBuilder(name: string) {
  BillType()
}

@Component
export struct BillType {
  @State private currentType: BillTypeKind = 'expense'
  @State private billTypes: BillTypeModel[] = []
  @State private showDeleteDialog: boolean = false
  @State private pendingDeleteId: string = ''
  @State private pendingDeleteName: string = ''

  aboutToAppear() {
    this.refreshList()
  }

  private async refreshList(): Promise<void> {
    this.billTypes = await BillTypeStore.listByType(this.currentType)
  }

  private async confirmDelete(): Promise<void> {
    if (this.pendingDeleteId.length > 0) {
      await BillTypeStore.remove(this.pendingDeleteId)
      this.pendingDeleteId = ''
      this.pendingDeleteName = ''
      this.showDeleteDialog = false
      await this.refreshList()
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column({ space: 0 }) {
          // 顶部 Tab 切换 + 新增按钮
          Row() {
            Row() {
              // 支出 Tab
              Text('支出')
                .fontSize(14)
                .fontWeight(this.currentType === 'expense' ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.currentType === 'expense' ? '#ffffff' : '#666666')
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .height(36)
                .backgroundColor(this.currentType === 'expense' ? '#d81e06' : Color.Transparent)
                .borderRadius(18)
                .onClick(async () => {
                  this.currentType = 'expense'
                  await this.refreshList()
                })

              // 收入 Tab
              Text('收入')
                .fontSize(14)
                .fontWeight(this.currentType === 'income' ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.currentType === 'income' ? '#ffffff' : '#666666')
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .height(36)
                .backgroundColor(this.currentType === 'income' ? '#36ab60' : Color.Transparent)
                .borderRadius(18)
                .onClick(async () => {
                  this.currentType = 'income'
                  await this.refreshList()
                })
            }
            .width(180)
            .height(40)
            .padding(2)
            .backgroundColor('#f2f2f5')
            .borderRadius(20)

            Blank()

            // 新增按钮
            Button('+ 新增')
              .type(ButtonType.Capsule)
              .height(36)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(this.currentType === 'expense' ? '#d81e06' : '#36ab60')
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
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })

          // 类型数量提示
          Row() {
            Text(`共 ${this.billTypes.length} 个${this.currentType === 'expense' ? '支出' : '收入'}类型`)
              .fontSize(12)
              .fontColor('#aaaaaa')
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 8 })

          // 列表区域
          if (this.billTypes.length === 0) {
            // 空状态
            Column({ space: 12 }) {
              Text('( . _ . )')
                .fontSize(40)
                .fontColor('#dddddd')
              Text('还没有类型，点击右上角新增吧')
                .fontSize(14)
                .fontColor('#bbbbbb')
            }
            .layoutWeight(1)
            .width('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            List({ space: 10 }) {
              ForEach(this.billTypes, (item: BillTypeModel) => {
                ListItem() {
                  Row() {
                    // 左侧图标圆圈
                    Row() {
                      Text(item.name.substring(0, 1))
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#ffffff')
                    }
                    .width(40)
                    .height(40)
                    .backgroundColor(item.type === 'expense' ? '#d81e06' : '#36ab60')
                    .borderRadius(20)
                    .justifyContent(FlexAlign.Center)
                    .margin({ right: 14 })

                    // 名称
                    Text(item.name)
                      .fontSize(16)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium)

                    Blank()

                    // 操作按钮
                    Row({ space: 8 }) {
                      Text('编辑')
                        .fontSize(12)
                        .fontColor(item.type === 'expense' ? '#d81e06' : '#36ab60')
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .backgroundColor(item.type === 'expense' ? '#fff3f1' : '#edf8f0')
                        .borderRadius(14)
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

                      Text('删除')
                        .fontSize(12)
                        .fontColor('#999999')
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .backgroundColor('#f5f5f5')
                        .borderRadius(14)
                        .onClick(() => {
                          this.pendingDeleteId = item.id
                          this.pendingDeleteName = item.name
                          this.showDeleteDialog = true
                        })
                    }
                  }
                  .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                  .width('100%')
                  .backgroundColor('#ffffff')
                  .borderRadius(14)
                  .shadow({
                    radius: 8,
                    color: 'rgba(0, 0, 0, 0.04)',
                    offsetX: 0,
                    offsetY: 2
                  })
                }
              }, (item: BillTypeModel): string => item.id)
            }
            .padding({ left: 16, right: 16 })
            .layoutWeight(1)
            .width('100%')
          }
        }
        .height('100%')
        .width('100%')
        .backgroundColor('#f5f5f8')

        // 删除确认弹窗遮罩
        if (this.showDeleteDialog) {
          Column() {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.45)')
              .onClick(() => {
                this.showDeleteDialog = false
              })
          }
          .width('100%')
          .height('100%')
          .position({ x: 0, y: 0 })

          // 弹窗内容
          Column({ space: 16 }) {
            Text('确认删除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')

            Text(`确定要删除类型「${this.pendingDeleteName}」吗？`)
              .fontSize(14)
              .fontColor('#666666')
              .textAlign(TextAlign.Center)

            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#f2f2f5')
                .fontColor('#666666')
                .type(ButtonType.Capsule)
                .onClick(() => {
                  this.showDeleteDialog = false
                })

              Button('确认删除')
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#d81e06')
                .fontColor('#ffffff')
                .type(ButtonType.Capsule)
                .onClick(async () => {
                  await this.confirmDelete()
                })
            }
            .width('100%')
          }
          .padding(24)
          .width('80%')
          .backgroundColor('#ffffff')
          .borderRadius(20)
          .shadow({
            radius: 24,
            color: 'rgba(0, 0, 0, 0.15)',
            offsetX: 0,
            offsetY: 4
          })
        }
      }
    }
    .title('账单类型')
    .onShown(() => {
      this.refreshList()
    })
  }
}
