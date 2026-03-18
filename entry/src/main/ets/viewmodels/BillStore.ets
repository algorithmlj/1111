import { BillModel, BillSummary } from '../models/BillModel'
import { BillTypeKind } from '../models/BillTypeModel'
import { ArkDataUtil } from '../utils/ArkDataUtil'

const KEY_PREFIX = 'bill_'

export class BillStore {

  /**
   * 查询账单列表，按月份 + 类型筛选
   */
  static async list(month: string, type: BillTypeKind | 'all'): Promise<BillModel[]> {
    const entries: string[] = await ArkDataUtil.getEntriesByPrefix(KEY_PREFIX)
    const results: BillModel[] = []
    for (let i = 0; i < entries.length; i++) {
      const item: BillModel = JSON.parse(entries[i]) as BillModel
      // 月份筛选：ctime 以 yyyy-MM 开头
      if (!item.ctime.startsWith(month)) {
        continue
      }
      // 类型筛选
      if (type !== 'all' && item.type !== type) {
        continue
      }
      results.push(item)
    }
    // 按日期倒序
    results.sort((a: BillModel, b: BillModel): number => {
      if (a.ctime > b.ctime) {
        return -1
      } else if (a.ctime < b.ctime) {
        return 1
      }
      return 0
    })
    return results
  }

  /**
   * 根据 id 查找
   */
  static async findById(id: string): Promise<BillModel | undefined> {
    const value: string = await ArkDataUtil.getString(KEY_PREFIX + id)
    if (value.length === 0) {
      return undefined
    }
    return JSON.parse(value) as BillModel
  }

  /**
   * 新增账单
   */
  static async create(bill: BillModel): Promise<void> {
    await ArkDataUtil.putString(KEY_PREFIX + bill.id, JSON.stringify(bill))
  }

  /**
   * 修改账单
   */
  static async update(bill: BillModel): Promise<boolean> {
    const existing: string = await ArkDataUtil.getString(KEY_PREFIX + bill.id)
    if (existing.length === 0) {
      return false
    }
    await ArkDataUtil.putString(KEY_PREFIX + bill.id, JSON.stringify(bill))
    return true
  }

  /**
   * 删除账单
   */
  static async remove(id: string): Promise<void> {
    await ArkDataUtil.delete(KEY_PREFIX + id)
  }

  /**
   * 按月统计收入和支出总额
   */
  static async sumByMonth(month: string): Promise<BillSummary> {
    const entries: string[] = await ArkDataUtil.getEntriesByPrefix(KEY_PREFIX)
    const result: BillSummary = new BillSummary()
    for (let i = 0; i < entries.length; i++) {
      const item: BillModel = JSON.parse(entries[i]) as BillModel
      if (!item.ctime.startsWith(month)) {
        continue
      }
      if (item.type === 'income') {
        result.income += item.money
      } else {
        result.expense += item.money
      }
    }
    return result
  }
}
