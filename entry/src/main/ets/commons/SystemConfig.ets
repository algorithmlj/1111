import { BarModel } from '../commons/BarModel'
import { distributedKVStore } from '@kit.ArkData'

export const pathStack: NavPathStack = new NavPathStack()

let kvManager: distributedKVStore.KVManager | undefined = undefined
let kvStore: distributedKVStore.SingleKVStore | undefined = undefined
const KV_STORE_ID = 'fzbill_store'

/**
 * 初始化 KVManager，需要在 EntryAbility.onCreate 中调用
 */
export function initKvManager(context: Context): void {
  const config: distributedKVStore.KVManagerConfig = {
    context: context,
    bundleName: context.applicationInfo.name
  }
  kvManager = distributedKVStore.createKVManager(config)
}

/**
 * 获取 SingleKVStore 实例（懒加载，首次调用时创建）
 */
export async function getKvStore(): Promise<distributedKVStore.SingleKVStore> {
  if (kvStore !== undefined) {
    return kvStore
  }
  if (kvManager === undefined) {
    throw new Error('KVManager 未初始化，请先调用 initKvManager')
  }
  const options: distributedKVStore.Options = {
    securityLevel:distributedKVStore.SecurityLevel.S3
  }
  try {
    kvStore = await kvManager.getKVStore<distributedKVStore.SingleKVStore>(KV_STORE_ID, options)
  } catch (e) {
    throw new Error('获取 KVStore 失败: ' + JSON.stringify(e))
  }
  return kvStore
}

export class SystemConfig {
  //底部导航的内容
  public static bars: BarModel[] = [
    {
      name: "首页",
      img1: "app.media.zhuye",
      img2: "app.media.zhuye1",
      color1: "#707070",
      color2: "#d81e06"
    },
    {
      name: "账单",
      img1: "app.media.zhangdan",
      img2: "app.media.zhangdan1",
      color1: "#707070",
      color2: "#d81e06"
    },
    {
      name: "AI管家",
      img1: "app.media.xiaoaiguanjia",
      img2: "app.media.xiaoaiguanjia1",
      color1: "#707070",
      color2: "#d81e06"
    },
    {
      name: "资产",
      img1: "app.media.zichan",
      img2: "app.media.zichan1",
      color1: "#707070",
      color2: "#d81e06"
    },
    {
      name: "统计",
      img1: "app.media.tongji",
      img2: "app.media.tongji1",
      color1: "#707070",
      color2: "#d81e06"
    },
  ]
}
