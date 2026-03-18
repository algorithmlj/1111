import { BillTypeKind } from './BillTypeModel'

export interface BillModel {
  id: string
  type: BillTypeKind    // 收入还是支出
  tname: string         // 账单类型名称
  ticon: string         // 账单类型图标（取首字）
  money: number         // 账单费用
  info: string          // 备注信息
  ctime: string         // 账单日期 yyyy-MM-dd
}

export interface BillEditParams {
  mode: 'create' | 'edit'
  billId?: string
}

export interface BillDetailParams {
  billId: string
}

export class BillSummary {
  income: number = 0
  expense: number = 0
}
