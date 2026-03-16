import { BillTypeKind, BillTypeModel } from './BillTypeModel'

export class BillTypeStore {
  private static items: BillTypeModel[] = [
    { id: 'expense-food', name: '餐饮', type: 'expense' },
    { id: 'expense-traffic', name: '交通', type: 'expense' },
    { id: 'income-salary', name: '工资', type: 'income' }
  ]

  static listByType(type: BillTypeKind): BillTypeModel[] {
    return BillTypeStore.items.filter(item => item.type === type)
  }

  static findById(id: string): BillTypeModel | undefined {
    return BillTypeStore.items.find(item => item.id === id)
  }

  static create(name: string, type: BillTypeKind): void {
    const now: string = Date.now().toString(36)
    const random: string = Math.floor(Math.random() * 10000).toString(36)
    BillTypeStore.items.unshift({
      id: `${type}-${now}-${random}`,
      name,
      type
    })
  }

  static update(id: string, name: string, type: BillTypeKind): boolean {
    const index: number = BillTypeStore.items.findIndex(item => item.id === id)
    if (index < 0) {
      return false
    }
    BillTypeStore.items[index] = { id, name, type }
    return true
  }

  static remove(id: string): void {
    BillTypeStore.items = BillTypeStore.items.filter(item => item.id !== id)
  }
}
