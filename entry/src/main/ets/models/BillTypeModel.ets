export type BillTypeKind = 'income' | 'expense'

export interface BillTypeModel {
  id: string
  name: string
  type: BillTypeKind
}

export interface BillTypeEditParams {
  mode: 'create' | 'edit'
  type: BillTypeKind
  id?: string
}
