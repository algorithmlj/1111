import { pathStack } from '../commons/SystemConfig'
import { BillEditParams, BillModel } from '../models/BillModel'
import { BillTypeKind, BillTypeModel } from '../models/BillTypeModel'
import { BillTypeStore } from '../viewmodels/BillTypeStore'
import { BillStore } from '../viewmodels/BillStore'

@Builder
export function BillEditBuilder(name: string) {
  BillEdit()
}

@Component
export struct BillEdit {
  @State private mode: 'create' | 'edit' = 'create'
  @State private editId: string = ''
  @State private type: BillTypeKind = 'expense'
  @State private tname: string = ''
  @State private ticon: string = ''
  @State private money: string = ''
  @State private info: string = ''
  @State private ctime: string = ''
  @State private errorText: string = ''
  // 可选的账单类型列表
  @State private typeOptions: BillTypeModel[] = []
  @State private showTypePicker: boolean = false

  private async initFromParams(params: BillEditParams): Promise<void> {
    this.mode = params.mode
    // 默认日期为今天
    const now: Date = new Date()
    const y: string = now.getFullYear().toString()
    const m: string = (now.getMonth() + 1).toString().padStart(2, '0')
    const d: string = now.getDate().toString().padStart(2, '0')
    this.ctime = `${y}-${m}-${d}`

    if (this.mode === 'edit' && typeof params.billId === 'string') {
      this.editId = params.billId
      const bill: BillModel | undefined = await BillStore.findById(this.editId)
      if (bill !== undefined) {
        this.type = bill.type
        this.tname = bill.tname
        this.ticon = bill.ticon
        this.money = bill.money.toString()
        this.info = bill.info
        this.ctime = bill.ctime
      }
    }
    await this.loadTypeOptions()
  }

  private async loadTypeOptions(): Promise<void> {
    this.typeOptions = await BillTypeStore.listByType(this.type)
  }

  private async submit(): Promise<void> {
    if (this.tname.length === 0) {
      this.errorText = '请选择账单类型'
      return
    }
    const moneyNum: number = parseFloat(this.money)
    if (isNaN(moneyNum) || moneyNum <= 0) {
      this.errorText = '请输入正确的金额'
      return
    }
    if (this.ctime.length === 0) {
      this.errorText = '请选择账单日期'
      return
    }

    if (this.mode === 'create') {
      const now: string = Date.now().toString(36)
      const random: string = Math.floor(Math.random() * 10000).toString(36)
      const bill: BillModel = {
        id: `bill_${now}_${random}`,
        type: this.type,
        tname: this.tname,
        ticon: this.ticon,
        money: moneyNum,
        info: this.info,
        ctime: this.ctime
      }
      await BillStore.create(bill)
    } else {
      const bill: BillModel = {
        id: this.editId,
        type: this.type,
        tname: this.tname,
        ticon: this.ticon,
        money: moneyNum,
        info: this.info,
        ctime: this.ctime
      }
      await BillStore.update(bill)
    }
    pathStack.pop()
  }

  build() {
    NavDestination() {
      Column({ space: 0 }) {
        Scroll() {
          Column({ space: 20 }) {

            // 收入/支出切换
            Column({ space: 10 }) {
              Text('账单方向')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              Row() {
                Row({ space: 6 }) {
                  Radio({ value: 'expense', group: 'billDir' })
                    .checked(this.type === 'expense')
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.type = 'expense'
                        this.tname = ''
                        this.ticon = ''
                        this.loadTypeOptions()
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

                Row().width(10)

                Row({ space: 6 }) {
                  Radio({ value: 'income', group: 'billDir' })
                    .checked(this.type === 'income')
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.type = 'income'
                        this.tname = ''
                        this.ticon = ''
                        this.loadTypeOptions()
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
              }
              .width('100%')
            }
            .width('100%')

            // 选择账单类型
            Column({ space: 10 }) {
              Text('账单类型')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              if (this.typeOptions.length === 0) {
                Text('暂无类型，请先到「类型管理」添加')
                  .fontSize(13)
                  .fontColor('#bbbbbb')
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })
              } else {
                // 类型网格
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.typeOptions, (opt: BillTypeModel) => {
                    Text(opt.name)
                      .fontSize(13)
                      .fontColor(this.tname === opt.name ? '#ffffff' :
                        (this.type === 'expense' ? '#d81e06' : '#36ab60'))
                      .backgroundColor(this.tname === opt.name ?
                        (this.type === 'expense' ? '#d81e06' : '#36ab60') :
                        (this.type === 'expense' ? '#fff3f1' : '#edf8f0'))
                      .borderRadius(16)
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .margin({ right: 8, bottom: 8 })
                      .onClick(() => {
                        this.tname = opt.name
                        this.ticon = opt.name.substring(0, 1)
                        this.errorText = ''
                      })
                  }, (opt: BillTypeModel): string => opt.id)
                }
                .width('100%')
              }
            }
            .width('100%')

            // 金额输入
            Column({ space: 10 }) {
              Text('金额')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              TextInput({ placeholder: '请输入金额', text: this.money })
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

            // 日期选择
            Column({ space: 10 }) {
              Text('日期')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')

              Row() {
                Text(this.ctime.length > 0 ? this.ctime : '请选择日期')
                  .fontSize(14)
                  .fontColor(this.ctime.length > 0 ? '#333333' : '#cccccc')

                Blank()

                Text('>')
                  .fontSize(14)
                  .fontColor('#cccccc')
              }
              .width('100%')
              .height(48)
              .padding({ left: 14, right: 14 })
              .backgroundColor('#f8f8fa')
              .borderRadius(12)
              .onClick(() => {
                this.getUIContext().showDatePickerDialog({
                  selected: new Date(this.ctime),
                  onDateAccept: (value: Date) => {
                    const y: string = value.getFullYear().toString()
                    const m: string = (value.getMonth() + 1).toString().padStart(2, '0')
                    const d: string = value.getDate().toString().padStart(2, '0')
                    this.ctime = `${y}-${m}-${d}`
                  }
                })
              })
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

          Button(this.mode === 'create' ? '确认记账' : '保存修改')
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
    .title(this.mode === 'create' ? '记一笔' : '修改账单')
    .onReady(async (context: NavDestinationContext) => {
      const params: BillEditParams | undefined = context.pathInfo?.param as BillEditParams | undefined
      if (params !== undefined) {
        await this.initFromParams(params)
      } else {
        // 默认新增模式
        const defaultParams: BillEditParams = { mode: 'create' }
        await this.initFromParams(defaultParams)
      }
    })
  }
}
