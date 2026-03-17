import { distributedKVStore } from '@kit.ArkData'
import { AssetModel, AssetSummary } from './AssetModel'
import { getKvStore } from './SystemConfig'

const KEY_PREFIX = 'asset_'

export class AssetStore {

  /**
   * 查询所有资产列表
   */
  static async list(): Promise<AssetModel[]> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    const results: AssetModel[] = []
    try {
      const entries: distributedKVStore.Entry[] = await store.getEntries(KEY_PREFIX)
      for (let i = 0; i < entries.length; i++) {
        const value: string = entries[i].value.value.toString()
        const item: AssetModel = JSON.parse(value) as AssetModel
        results.push(item)
      }
    } catch (_e) {
      // ignore
    }
    // 按金额降序排列
    results.sort((a: AssetModel, b: AssetModel): number => {
      return b.money - a.money
    })
    return results
  }

  /**
   * 根据 id 查找单条资产
   */
  static async findById(id: string): Promise<AssetModel | undefined> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      const value: string = (await store.get(KEY_PREFIX + id)).toString()
      return JSON.parse(value) as AssetModel
    } catch (_e) {
      return undefined
    }
  }

  /**
   * 新增资产
   */
  static async create(asset: AssetModel): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      await store.put(KEY_PREFIX + asset.id, JSON.stringify(asset))
    } catch (_e) {
      // ignore
    }
  }

  /**
   * 修改资产
   */
  static async update(asset: AssetModel): Promise<boolean> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    try {
      await store.get(KEY_PREFIX + asset.id)
      await store.put(KEY_PREFIX + asset.id, JSON.stringify(asset))
      return true
    } catch (_e) {
      return false
    }
  }

  /**
   * 删除资产
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
   * 计算资产总额
   */
  static async totalMoney(): Promise<number> {
    const summary: AssetSummary = await AssetStore.summary()
    return summary.net
  }

  /**
   * 计算资产汇总：资产、负债、净资产
   */
  static async summary(): Promise<AssetSummary> {
    const store: distributedKVStore.SingleKVStore = await getKvStore()
    const result: AssetSummary = new AssetSummary()
    try {
      const entries: distributedKVStore.Entry[] = await store.getEntries(KEY_PREFIX)
      for (let i = 0; i < entries.length; i++) {
        const value: string = entries[i].value.value.toString()
        const item: AssetModel = JSON.parse(value) as AssetModel
        if (item.money >= 0) {
          result.asset += item.money
        } else {
          result.liability += Math.abs(item.money)
        }
      }
    } catch (_e) {
      // ignore
    }
    result.net = result.asset - result.liability
    return result
  }
}
