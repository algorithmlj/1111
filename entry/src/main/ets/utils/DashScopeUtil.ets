import { http } from '@kit.NetworkKit'
import { util } from '@kit.ArkTS'
import { ChatMessage, DashScopeInput, DashScopeParameters, DashScopeRequest, DashScopeResponse } from '../models/ChatModel'

/**
 * 阿里云百炼 DashScope AI 大模型工具类
 * 支持普通请求和流式请求两种方式
 */
export class DashScopeUtil {
  // 阿里云百炼接口地址
  private static readonly BASE_URL: string =
    'https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation'

  // API Key - 请替换为你的 DashScope API Key
  private static readonly API_KEY: string = 'sk-889d3d457ade466b8566b8869819723b'

  // 默认模型
  private static readonly DEFAULT_MODEL: string = 'qwen-plus'

  // 系统提示词（基础部分）
  private static readonly SYSTEM_PROMPT: string =
    '你是一个智能AI管家，专注于帮助用户管理财务和日常生活。你可以回答关于记账、理财、资产管理等问题，也可以进行日常对话。请用简洁友好的语言回复。'

  // 账单分析提示词（当有账单数据时附加）
  private static readonly BILL_ANALYSIS_PROMPT: string =
    '\n\n你同时具备财务分析能力。以下是用户近一个月的账单记录，你可以基于这些数据回答用户关于消费情况、支出分析、理财建议等问题。如果用户没有问到账单相关的问题，则不需要主动提及账单数据。'

  /**
   * 构建请求体
   * @param messages 对话消息列表
   * @param stream 是否流式输出
   * @param billSummary 账单摘要文本（可选），会附加到系统提示词中
   * @returns 请求体JSON字符串
   */
  private static buildRequestBody(messages: ChatMessage[], stream: boolean, billSummary?: string): string {
    // 构建系统提示词：基础提示 + 账单数据（如果有）
    let systemContent: string = DashScopeUtil.SYSTEM_PROMPT
    if (billSummary !== undefined && billSummary.length > 0) {
      systemContent += DashScopeUtil.BILL_ANALYSIS_PROMPT + '\n\n' + billSummary
    }

    const systemMsg: ChatMessage = { role: 'system', content: systemContent }
    const fullMessages: ChatMessage[] = [systemMsg]
    for (const msg of messages) {
      fullMessages.push(msg)
    }

    const input: DashScopeInput = { messages: fullMessages }
    const parameters: DashScopeParameters = {
      result_format: 'message',
      incremental_output: stream
    }
    const body: DashScopeRequest = {
      model: DashScopeUtil.DEFAULT_MODEL,
      input: input,
      parameters: parameters
    }
    return JSON.stringify(body)
  }

  /**
   * 方式一：普通请求（一次性返回完整结果）
   * @param messages 对话消息列表
   * @param billSummary 账单摘要（可选）
   * @returns Promise<string> AI回复内容
   */
  static async requestNormal(messages: ChatMessage[], billSummary?: string): Promise<string> {
    const httpRequest = http.createHttp()

    try {
      const response = await httpRequest.request(DashScopeUtil.BASE_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${DashScopeUtil.API_KEY}`
        },
        extraData: DashScopeUtil.buildRequestBody(messages, false, billSummary),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30000,
        readTimeout: 60000
      })

      if (response.responseCode === 200) {
        const result: DashScopeResponse = JSON.parse(response.result as string) as DashScopeResponse
        if (result.output && result.output.choices && result.output.choices.length > 0) {
          return result.output.choices[0].message.content
        }
        return '抱歉，未能获取到回复内容。'
      } else {
        console.error(`DashScope请求失败，状态码: ${response.responseCode}`)
        return `请求失败，错误码: ${response.responseCode}`
      }
    } catch (err) {
      console.error(`DashScope请求异常: ${JSON.stringify(err)}`)
      return '网络请求异常，请检查网络连接后重试。'
    } finally {
      httpRequest.destroy()
    }
  }

  /**
   * 方式二：流式请求（逐步返回内容，实时更新）
   * @param messages 对话消息列表
   * @param onData 每次收到数据的回调，参数为本次增量内容
   * @param onComplete 流式请求完成的回调
   * @param onError 错误回调
   * @param billSummary 账单摘要（可选）
   */
  static requestStream(
    messages: ChatMessage[],
    onData: (chunk: string) => void,
    onComplete: () => void,
    onError: (error: string) => void,
    billSummary?: string
  ): void {
    const httpRequest = http.createHttp()

    // 监听流式数据返回（headersReceive 用于接收流式数据事件）
    httpRequest.on('dataReceive', (data: ArrayBuffer) => {
      // 将 ArrayBuffer 转换为字符串
      const textDecoder = new util.TextDecoder('utf-8')
      const chunk = textDecoder.decodeToString(new Uint8Array(data))

      // 流式返回的数据可能包含多行，每行以 "data:" 开头
      const lines = chunk.split('\n')
      for (const line of lines) {
        const trimmedLine = line.trim()
        if (trimmedLine.startsWith('data:')) {
          const jsonStr = trimmedLine.substring(5).trim()
          if (jsonStr === '[DONE]') {
            continue
          }
          try {
            const result: DashScopeResponse = JSON.parse(jsonStr) as DashScopeResponse
            if (result.output && result.output.choices && result.output.choices.length > 0) {
              const content = result.output.choices[0].message.content
              if (content) {
                onData(content)
              }
            }
          } catch (e) {
            // 非标准 SSE 格式，尝试直接解析整个 chunk
            try {
              const result: DashScopeResponse = JSON.parse(trimmedLine) as DashScopeResponse
              if (result.output && result.output.choices && result.output.choices.length > 0) {
                const content = result.output.choices[0].message.content
                if (content) {
                  onData(content)
                }
              }
            } catch (_e) {
              // 忽略解析异常的片段
            }
          }
        } else if (trimmedLine.length > 0 && trimmedLine.startsWith('{')) {
          // 有些情况下直接返回 JSON，没有 data: 前缀
          try {
            const result: DashScopeResponse = JSON.parse(trimmedLine) as DashScopeResponse
            if (result.output && result.output.choices && result.output.choices.length > 0) {
              const content = result.output.choices[0].message.content
              if (content) {
                onData(content)
              }
            }
          } catch (_e) {
            // 忽略
          }
        }
      }
    })

    // 监听流式请求完成
    httpRequest.on('dataEnd', () => {
      onComplete()
      httpRequest.destroy()
    })

    // 发起流式请求
    httpRequest.requestInStream(DashScopeUtil.BASE_URL, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${DashScopeUtil.API_KEY}`,
        'X-DashScope-SSE': 'enable'
      },
      extraData: DashScopeUtil.buildRequestBody(messages, true, billSummary),
      connectTimeout: 30000,
      readTimeout: 120000
    }).then((code: number) => {
      if (code !== 200) {
        onError(`请求失败，HTTP状态码: ${code}`)
        httpRequest.destroy()
      }
    }).catch((err: Error) => {
      onError(`网络请求异常: ${err.message}`)
      httpRequest.destroy()
    })
  }
}
