import { AssetModel, AssetSummary } from '../models/AssetModel'
import { ArkDataUtil } from '../utils/ArkDataUtil'

const KEY_PREFIX = 'asset_'

export class AssetStore {

  /**
   * 查询所有资产列表
   */
  static async list(): Promise<AssetModel[]> {
    const entries: string[] = await ArkDataUtil.getEntriesByPrefix(KEY_PREFIX)
    const results: AssetModel[] = []
    for (let i = 0; i < entries.length; i++) {
      results.push(JSON.parse(entries[i]) as AssetModel)
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
    const value: string = await ArkDataUtil.getString(KEY_PREFIX + id)
    if (value.length === 0) {
      return undefined
    }
    return JSON.parse(value) as AssetModel
  }

  /**
   * 新增资产
   */
  static async create(asset: AssetModel): Promise<void> {
    await ArkDataUtil.putString(KEY_PREFIX + asset.id, JSON.stringify(asset))
  }

  /**
   * 修改资产
   */
  static async update(asset: AssetModel): Promise<boolean> {
    const existing: string = await ArkDataUtil.getString(KEY_PREFIX + asset.id)
    if (existing.length === 0) {
      return false
    }
    await ArkDataUtil.putString(KEY_PREFIX + asset.id, JSON.stringify(asset))
    return true
  }

  /**
   * 删除资产
   */
  static async remove(id: string): Promise<void> {
    await ArkDataUtil.delete(KEY_PREFIX + id)
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
    const entries: string[] = await ArkDataUtil.getEntriesByPrefix(KEY_PREFIX)
    const result: AssetSummary = new AssetSummary()
    for (let i = 0; i < entries.length; i++) {
      const item: AssetModel = JSON.parse(entries[i]) as AssetModel
      if (item.money >= 0) {
        result.asset += item.money
      } else {
        result.liability += Math.abs(item.money)
      }
    }
    result.net = result.asset - result.liability
    return result
  }
}
