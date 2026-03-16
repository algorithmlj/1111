import { pathStack } from '../commons/SystemConfig'
import { BillTypeEditParams, BillTypeKind, BillTypeModel } from '../commons/BillTypeModel'
import { BillTypeStore } from '../commons/BillTypeStore'

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

  private initFromParams(params: BillTypeEditParams) {
    this.mode = params.mode
    this.type = params.type
    if (typeof params.id === 'string') {
      this.editId = params.id
    }
    if (this.mode === 'edit' && this.editId.length > 0) {
      const item: BillTypeModel | undefined = BillTypeStore.findById(this.editId)
      if (item !== undefined) {
        this.name = item.name
        this.type = item.type
      }
    }
  }

  @Builder
  private typeButton(label: string, value: BillTypeKind) {
    Button(label)
      .type(ButtonType.Capsule)
      .backgroundColor(this.type === value ? '#d81e06' : '#f3f3f3')
      .fontColor(this.type === value ? '#ffffff' : '#333333')
      .onClick(() => {
        this.type = value
      })
  }

  private submit() {
    const name: string = this.name.trim()
    if (name.length === 0) {
      this.errorText = '请输入账单类型名称'
      return
    }
    if (this.mode === 'create') {
      BillTypeStore.create(name, this.type)
    } else {
      BillTypeStore.update(this.editId, name, this.type)
    }
    pathStack.pop()
  }

  build() {
    NavDestination() {
      Column({ space: 14 }) {
        Row({ space: 8 }) {
          this.typeButton('支出', 'expense')
          this.typeButton('收入', 'income')
        }

        Column({ space: 6 }) {
          Text('类型名称')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Start)
          TextInput({ placeholder: '例如：餐饮、房租、工资', text: this.name })
            .onChange(value => {
              this.name = value
              if (value.trim().length > 0) {
                this.errorText = ''
              }
            })
            .width('100%')
        }
        .width('100%')

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(12)
            .fontColor('#d81e06')
            .width('100%')
            .textAlign(TextAlign.Start)
        }

        Row({ space: 10 }) {
          Button('取消')
            .width('48%')
            .backgroundColor('#f0f0f0')
            .fontColor('#333333')
            .onClick(() => {
              pathStack.pop()
            })
          Button(this.mode === 'create' ? '确认新增' : '确认修改')
            .width('48%')
            .backgroundColor('#d81e06')
            .onClick(() => {
              this.submit()
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
      }
      .padding(16)
      .height('100%')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .title(this.mode === 'create' ? '新增账单类型' : '编辑账单类型')
    .onReady(context => {
      const params: BillTypeEditParams | undefined = context.pathInfo?.param as BillTypeEditParams | undefined
      if (params !== undefined) {
        this.initFromParams(params)
      }
    })
  }
}
