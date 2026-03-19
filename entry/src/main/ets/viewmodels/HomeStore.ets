import { BillModel, BillSummary } from '../models/BillModel'
import { AssetSummary } from '../models/AssetModel'
import { BillStore } from './BillStore'
import { AssetStore } from './AssetStore'
import { ArkDataUtil } from '../utils/ArkDataUtil'

export enum HealthStatus {
  NORMAL = 'normal',
  ATTENTION = 'attention',
  WARNING = 'warning'
}

export interface Insight {
  type: 'warning' | 'attention' | 'info'
  message: string
  actionText: string
}

export class HomeStore {

  static async getCurrentMonth(): Promise<string> {
    const now: Date = new Date()
    const y: string = now.getFullYear().toString()
    const m: string = (now.getMonth() + 1).toString().padStart(2, '0')
    return `${y}-${m}`
  }

  static async getMonthSummary(month: string): Promise<BillSummary> {
    return await BillStore.sumByMonth(month)
  }

  static async getRecentBills(days: number = 7): Promise<BillModel[]> {
    const entries: string[] = await ArkDataUtil.getEntriesByPrefix('bill_')
    const now = new Date()
    const startTime = now.getTime() - days * 24 * 60 * 60 * 1000
    const results: BillModel[] = []
    for (let i = 0; i < entries.length; i++) {
      const item: BillModel = JSON.parse(entries[i]) as BillModel
      const parts = item.ctime.split('-')
      if (parts.length === 3) {
        const itemDate = new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]))
        if (itemDate.getTime() >= startTime) {
          results.push(item)
        }
      }
    }
    results.sort((a: BillModel, b: BillModel): number => {
      if (a.ctime > b.ctime) return -1
      else if (a.ctime < b.ctime) return 1
      return 0
    })
    return results
  }

  static async getAssetSummary(): Promise<AssetSummary> {
    return await AssetStore.summary()
  }

  static calculateBalance(summary: BillSummary): number {
    return summary.income - summary.expense
  }

  static async evaluateHealthStatus(): Promise<HealthStatus> {
    const now: Date = new Date()
    const currentMonth: string = await HomeStore.getCurrentMonth()
    const summary: BillSummary = await HomeStore.getMonthSummary(currentMonth)

    if (summary.expense > summary.income && summary.income > 0) {
      return HealthStatus.WARNING
    }

    const thisWeekExpense: number = await HomeStore.getWeekExpense(now)
    const lastWeekExpense: number = await HomeStore.getWeekExpense(new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000))

    if (lastWeekExpense > 0 && thisWeekExpense > lastWeekExpense * 1.5) {
      return HealthStatus.ATTENTION
    }

    return HealthStatus.NORMAL
  }

  private static async getWeekExpense(date: Date): Promise<number> {
    const entries: string[] = await ArkDataUtil.getEntriesByPrefix('bill_')
    let total: number = 0
    const startOfWeek: Date = new Date(date)
    startOfWeek.setDate(date.getDate() - date.getDay())
    startOfWeek.setHours(0, 0, 0, 0)

    for (let i = 0; i < entries.length; i++) {
      const item: BillModel = JSON.parse(entries[i]) as BillModel
      if (item.type !== 'expense') continue

      const parts = item.ctime.split('-')
      if (parts.length !== 3) continue

      const itemDate: Date = new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]))
      if (itemDate >= startOfWeek && itemDate <= date) {
        total += item.money
      }
    }
    return total
  }

  static async generateInsight(): Promise<Insight | null> {
    const currentMonth: string = await HomeStore.getCurrentMonth()
    const summary: BillSummary = await HomeStore.getMonthSummary(currentMonth)
    const recentBills: BillModel[] = await HomeStore.getRecentBills(7)

    if (summary.income > 0 && summary.expense > summary.income) {
      return {
        type: 'warning',
        message: '本月支出超过收入，注意控制消费',
        actionText: '查看账单'
      }
    }

    const largeExpense: BillModel | undefined = recentBills.find((bill: BillModel) => {
      if (bill.type !== 'expense') return false
      const avgDailyExpense: number = summary.expense / 30
      return bill.money > avgDailyExpense * 3
    })

    if (largeExpense) {
      return {
        type: 'attention',
        message: `有一笔大额支出：${largeExpense.tname} ¥${largeExpense.money.toFixed(0)}`,
        actionText: '查看详情'
      }
    }

    const typeExpenses: Map<string, number> = new Map()
    for (const bill of recentBills) {
      if (bill.type !== 'expense') continue
      const current: number = typeExpenses.get(bill.tname) || 0
      typeExpenses.set(bill.tname, current + bill.money)
    }

    let topType: string = ''
    let topAmount: number = 0
    typeExpenses.forEach((amount: number, type: string) => {
      if (amount > topAmount) {
        topAmount = amount
        topType = type
      }
    })

    if (topType && topAmount > 200) {
      return {
        type: 'info',
        message: `本周${topType}支出 ¥${topAmount.toFixed(0)}，占比最高`,
        actionText: '查看详情'
      }
    }

    return null
  }
}
