/**
 * 数据存储工具类 - 封装键值型数据库(KVStore)操作
 */
import { distributedKVStore } from '@kit.ArkData'

export class ArkDataUtil {
  private static readonly KV_STORE_ID = 'fzbill_store'
  private static kvManager: distributedKVStore.KVManager | undefined = undefined
  private static kvStore: distributedKVStore.SingleKVStore | undefined = undefined

  /**
   * 初始化，需要在 EntryAbility.onCreate 中调用
   */
  public static init(context: Context): void {
    const config: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: context.applicationInfo.name
    }
    ArkDataUtil.kvManager = distributedKVStore.createKVManager(config)
  }

  /**
   * 获取 SingleKVStore 实例（懒加载）
   */
  private static async getStore(): Promise<distributedKVStore.SingleKVStore> {
    if (ArkDataUtil.kvStore !== undefined) {
      return ArkDataUtil.kvStore
    }
    if (ArkDataUtil.kvManager === undefined) {
      throw new Error('KVManager 未初始化，请先调用 ArkDataUtil.init')
    }
    const options: distributedKVStore.Options = {
      securityLevel: distributedKVStore.SecurityLevel.S3
    }
    ArkDataUtil.kvStore =
      await ArkDataUtil.kvManager.getKVStore<distributedKVStore.SingleKVStore>(ArkDataUtil.KV_STORE_ID, options)
    return ArkDataUtil.kvStore
  }

  // ==================== KVStore 操作 ====================

  /**
   * 写入字符串
   */
  public static async putString(key: string, value: string): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await ArkDataUtil.getStore()
    try {
      await store.put(key, value)
    } catch (e) {
      console.error(`KVStore put 失败: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 读取字符串
   */
  public static async getString(key: string): Promise<string> {
    const store: distributedKVStore.SingleKVStore = await ArkDataUtil.getStore()
    try {
      return (await store.get(key)).toString()
    } catch (_e) {
      return ''
    }
  }

  /**
   * 删除指定 key
   */
  public static async delete(key: string): Promise<void> {
    const store: distributedKVStore.SingleKVStore = await ArkDataUtil.getStore()
    try {
      await store.delete(key)
    } catch (e) {
      console.error(`KVStore delete 失败: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 按前缀查询所有条目，返回 value 字符串数组
   */
  public static async getEntriesByPrefix(prefix: string): Promise<string[]> {
    const store: distributedKVStore.SingleKVStore = await ArkDataUtil.getStore()
    const results: string[] = []
    try {
      const entries: distributedKVStore.Entry[] = await store.getEntries(prefix)
      for (let i = 0; i < entries.length; i++) {
        results.push(entries[i].value.value.toString())
      }
    } catch (_e) {
      // 无数据时可能抛异常，返回空数组
    }
    return results
  }
}
