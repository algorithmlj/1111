/**
 * 资产类型枚举
 */
export type AssetType = '现金' | '花呗' | '信用卡' | '抖音月付' | '储蓄卡' | '支付宝' | '微信' | '其他'

/**
 * 所有可选的资产类型列表
 */
export const ASSET_TYPE_LIST: AssetType[] = [
  '现金', '储蓄卡', '信用卡', '支付宝', '微信', '花呗', '抖音月付', '其他'
]

/**
 * 资产类型对应的图标字符（取首字）
 */
export function getAssetIcon(type: AssetType): string {
  return type.substring(0, 1)
}

/**
 * 资产类型对应的主题色
 */
export function getAssetColor(type: AssetType): string {
  if (type === '现金') {
    return '#36ab60'
  } else if (type === '储蓄卡') {
    return '#4a90d9'
  } else if (type === '信用卡') {
    return '#d81e06'
  } else if (type === '支付宝') {
    return '#1677ff'
  } else if (type === '微信') {
    return '#07c160'
  } else if (type === '花呗') {
    return '#ff6b35'
  } else if (type === '抖音月付') {
    return '#333333'
  } else {
    return '#888888'
  }
}

/**
 * 资产数据模型
 */
export interface AssetModel {
  id: string
  type: AssetType       // 资产类型
  icon: string          // 图标（取类型首字）
  name: string          // 资产名称
  money: number         // 金额
  info: string          // 备注
}

/**
 * 新增/编辑页面参数
 */
export interface AssetEditParams {
  mode: 'create' | 'edit'
  assetId?: string
}

/**
 * 详情页面参数
 */
export interface AssetDetailParams {
  assetId: string
}

/**
 * 资产汇总：资产、负债、净资产
 */
export class AssetSummary {
  asset: number = 0      // 资产总额（money >= 0）
  liability: number = 0  // 负债总额（money < 0 的绝对值）
  net: number = 0        // 净资产 = asset - liability
}
