import { distributedKVStore } from '@kit.ArkData'
import { BillModel, BillSummary } from './BillModel'
import { BillTypeKind } from './BillTypeModel'
import { getKvStore } from './SystemConfig'

const KEY_PREFIX = 'bill_'

export class BillStore {

  /**
   * 查询账单列表，按月份 + 类型筛选
   */
  static async list(month: string, type: BillTypeKind | 'all'): Promise<BillModel[]> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    const results: BillModel[] = []
    try {
      const entries: distributedKVStore.Entry[] = await store.getEntries(KEY_PREFIX)
      for (let i = 0; i < entries.length; i++) {
        const value: string = entries[i].value.value.toString()
        const item: BillModel = JSON.parse(value) as BillModel
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
    } catch (_e) {
      // ignore
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
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      const value: string = (await store.get(KEY_PREFIX + id)).toString()
      return JSON.parse(value) as BillModel
    } catch (_e) {
      return undefined
    }
  }

  /**
   * 新增账单
   */
  static async create(bill: BillModel): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      await store.put(KEY_PREFIX + bill.id, JSON.stringify(bill))
    } catch (_e) {
      // ignore
    }
  }

  /**
   * 修改账单
   */
  static async update(bill: BillModel): Promise<boolean> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      await store.get(KEY_PREFIX + bill.id)
      await store.put(KEY_PREFIX + bill.id, JSON.stringify(bill))
      return true
    } catch (_e) {
      return false
    }
  }

  /**
   * 删除账单
   */
  static async remove(id: string): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      await store.delete(KEY_PREFIX + id)
    } catch (_e) {
      // ignore
    }
  }

  /**
   * 按月统计收入和支出总额
   */
  static async sumByMonth(month: string): Promise<BillSummary> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    const result: BillSummary = new BillSummary()
    try {
      const entries: distributedKVStore.Entry[] = await store.getEntries(KEY_PREFIX)
      for (let i = 0; i < entries.length; i++) {
        const value: string = entries[i].value.value.toString()
        const item: BillModel = JSON.parse(value) as BillModel
        if (!item.ctime.startsWith(month)) {
          continue
        }
        if (item.type === 'income') {
          result.income += item.money
        } else {
          result.expense += item.money
        }
      }
    } catch (_e) {
      // ignore
    }
    return result
  }
}
