import { distributedKVStore } from '@kit.ArkData'
import { BillTypeKind, BillTypeModel } from './BillTypeModel'
import { getKvStore } from './SystemConfig'

// KV 键名：用统一前缀 + id 存储每条记录，值为 JSON 字符串
// 格式：billtype_{id} -> JSON.stringify(BillTypeModel)
const KEY_PREFIX = 'billtype_'

export class BillTypeStore {

  /**
   * 查询指定类型的所有账单类型
   */
  static async listByType(type: BillTypeKind): Promise<BillTypeModel[]> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    const results: BillTypeModel[] = []
    try {
      const entries: distributedKVStore.Entry[] = await store.getEntries(KEY_PREFIX)
      for (let i = 0; i < entries.length; i++) {
        const value: string = entries[i].value.value.toString()
        const item: BillTypeModel = JSON.parse(value) as BillTypeModel
        if (item.type === type) {
          results.push(item)
        }
      }
    } catch (_e) {
      // 无数据时 getEntries 可能抛异常，返回空数组即可
    }
    return results
  }

  /**
   * 根据 id 查找单条记录
   */
  static async findById(id: string): Promise<BillTypeModel | undefined> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      const value: string = (await store.get(KEY_PREFIX + id)).toString()
      return JSON.parse(value) as BillTypeModel
    } catch (_e) {
      return undefined
    }
  }

  /**
   * 新增账单类型
   */
  static async create(name: string, type: BillTypeKind): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    const now: string = Date.now().toString(36)
    const random: string = Math.floor(Math.random() * 10000).toString(36)
    const id: string = `${type}_${now}_${random}`
    const item: BillTypeModel = { id, name, type }
    try {
      await store.put(KEY_PREFIX + id, JSON.stringify(item))
    } catch (_e) {
      // ignore
    }
  }

  /**
   * 修改账单类型
   */
  static async update(id: string, name: string, type: BillTypeKind): Promise<boolean> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      await store.get(KEY_PREFIX + id)
      const item: BillTypeModel = { id, name, type }
      await store.put(KEY_PREFIX + id, JSON.stringify(item))
      return true
    } catch (_e) {
      return false
    }
  }

  /**
   * 删除账单类型
   */
  static async remove(id: string): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      await store.delete(KEY_PREFIX + id)
    } catch (_e) {
      // ignore
    }
  }
}
