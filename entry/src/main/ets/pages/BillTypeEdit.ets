import { pathStack } from '../commons/SystemConfig'
import { BillTypeEditParams, BillTypeKind, BillTypeModel } from '../models/BillTypeModel'
import { BillTypeStore } from '../viewmodels/BillTypeStore'

@Builder
export function BillTypeEditBuilder(name: string, param: BillTypeEditParams) {
  BillTypeEdit()
}

@Component
export struct BillTypeEdit {
  @State private mode: 'create' | 'edit' = 'create'
  @State private editId: string = ''
  @State private type: BillTypeKind = 'expense'
  @State private name: string = ''
  @State private errorText: string = ''

  private async initFromParams(params: BillTypeEditParams): Promise<void> {
    this.mode = params.mode
    this.type = params.type
    if (typeof params.id === 'string') {
      this.editId = params.id
    }
    if (this.mode === 'edit' && this.editId.length > 0) {
      const item: BillTypeModel | undefined = await BillTypeStore.findById(this.editId)
      if (item !== undefined) {
        this.name = item.name
        this.type = item.type
      }
    }
  }

  private async submit(): Promise<void> {
    const name: string = this.name.trim()
    console.log(this.mode)
    if (name.length === 0) {
      this.errorText = '请输入账单类型名称'
      return
    }
    if (this.mode === 'create') {
      await BillTypeStore.create(name, this.type)
    } else {
      await BillTypeStore.update(this.editId, name, this.type)
    }
    pathStack.pop()
  }

  build() {
    NavDestination() {
      Column({ space: 0 }) {
        // 表单卡片
        Column({ space: 20 }) {

          // 类型切换
          Column({ space: 10 }) {
            Text('账单方向')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            Row() {
              // 支出选项
              Row({ space: 6 }) {
                Radio({ value: 'expense', group: 'billType' })
                  .checked(this.type === 'expense')
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.type = 'expense'
                    }
                  })
                Text('支出')
                  .fontSize(14)
                  .fontColor(this.type === 'expense' ? '#d81e06' : '#999999')
                  .fontWeight(this.type === 'expense' ? FontWeight.Bold : FontWeight.Normal)
              }
              .layoutWeight(1)
              .height(44)
              .padding({ left: 12 })
              .backgroundColor(this.type === 'expense' ? '#fff3f1' : '#f8f8fa')
              .borderRadius(12)
              .onClick(() => {
                this.type = 'expense'
              })

              Row()
                .width(10)

              // 收入选项
              Row({ space: 6 }) {
                Radio({ value: 'income', group: 'billType' })
                  .checked(this.type === 'income')
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.type = 'income'
                    }
                  })
                Text('收入')
                  .fontSize(14)
                  .fontColor(this.type === 'income' ? '#36ab60' : '#999999')
                  .fontWeight(this.type === 'income' ? FontWeight.Bold : FontWeight.Normal)
              }
              .layoutWeight(1)
              .height(44)
              .padding({ left: 12 })
              .backgroundColor(this.type === 'income' ? '#edf8f0' : '#f8f8fa')
              .borderRadius(12)
              .onClick(() => {
                this.type = 'income'
              })
            }
            .width('100%')
          }
          .width('100%')

          // 名称输入
          Column({ space: 10 }) {
            Text('类型名称')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')

            TextInput({ placeholder: '例如：餐饮、房租、工资' ,text:this.name})
              .onChange((value: string) => {
                this.name = value
                if (value.trim().length > 0) {
                  this.errorText = ''
                }
              })
              .height(48)
              .borderRadius(12)
              .backgroundColor('#f8f8fa')
              .width('100%')

            if (this.errorText.length > 0) {
              Text(this.errorText)
                .fontSize(12)
                .fontColor('#d81e06')
                .width('100%')
                .padding({ left: 4 })
            }
          }
          .width('100%')
        }
        .padding(20)
        .margin(16)
        .backgroundColor('#ffffff')
        .borderRadius(16)
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.06)',
          offsetX: 0,
          offsetY: 2
        })

        Blank()

        // 底部按钮区
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

          Button(this.mode === 'create' ? '确认新增' : '保存修改')
            .layoutWeight(1)
            .height(46)
            .type(ButtonType.Capsule)
            .backgroundColor(this.type === 'expense' ? '#d81e06' : '#36ab60')
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
    .title(this.mode === 'create' ? '新增账单类型' : '编辑账单类型')
    .onReady(async (context: NavDestinationContext) => {
      const params: BillTypeEditParams | undefined = context.pathInfo?.param as BillTypeEditParams | undefined
      if (params !== undefined) {
        await this.initFromParams(params)
      }
    })
  }
}
