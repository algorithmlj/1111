import { BillTypeKind, BillTypeModel } from '../models/BillTypeModel'
import { ArkDataUtil } from '../utils/ArkDataUtil'

// KV 键名：用统一前缀 + id 存储每条记录，值为 JSON 字符串
// 格式：billtype_{id} -> JSON.stringify(BillTypeModel)
const KEY_PREFIX = 'billtype_'

export class BillTypeStore {

  /**
   * 查询指定类型的所有账单类型
   */
  static async listByType(type: BillTypeKind): Promise<BillTypeModel[]> {
    const entries: string[] = await ArkDataUtil.getEntriesByPrefix(KEY_PREFIX)
    const results: BillTypeModel[] = []
    for (let i = 0; i < entries.length; i++) {
      const item: BillTypeModel = JSON.parse(entries[i]) as BillTypeModel
      if (item.type === type) {
        results.push(item)
      }
    }
    return results
  }

  /**
   * 根据 id 查找单条记录
   */
  static async findById(id: string): Promise<BillTypeModel | undefined> {
    const value: string = await ArkDataUtil.getString(KEY_PREFIX + id)
    if (value.length === 0) {
      return undefined
    }
    return JSON.parse(value) as BillTypeModel
  }

  /**
   * 新增账单类型
   */
  static async create(name: string, type: BillTypeKind): Promise<void> {
    const now: string = Date.now().toString(36)
    const random: string = Math.floor(Math.random() * 10000).toString(36)
    const id: string = `${type}_${now}_${random}`
    const item: BillTypeModel = { id, name, type }
    await ArkDataUtil.putString(KEY_PREFIX + id, JSON.stringify(item))
  }

  /**
   * 修改账单类型
   */
  static async update(id: string, name: string, type: BillTypeKind): Promise<boolean> {
    const existing: string = await ArkDataUtil.getString(KEY_PREFIX + id)
    if (existing.length === 0) {
      return false
    }
    const item: BillTypeModel = { id, name, type }
    await ArkDataUtil.putString(KEY_PREFIX + id, JSON.stringify(item))
    return true
  }

  /**
   * 删除账单类型
   */
  static async remove(id: string): Promise<void> {
    await ArkDataUtil.delete(KEY_PREFIX + id)
  }
}
