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

  // 系统提示词
  private static readonly SYSTEM_PROMPT: string = '你是一个智能AI管家，专注于帮助用户管理财务和日常生活。你可以回答关于记账、理财、资产管理等问题，也可以进行日常对话。请用简洁友好的语言回复。'

  /**
   * 构建请求体
   * @param messages 对话消息列表
   * @param stream 是否流式输出
   * @returns 请求体JSON字符串
   */
  private static buildRequestBody(messages: ChatMessage[], stream: boolean): string {
    // 在消息列表前添加系统提示词
    const systemMsg: ChatMessage = { role: 'system', content: DashScopeUtil.SYSTEM_PROMPT }
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
   * @returns Promise<string> AI回复内容
   */
  static async requestNormal(messages: ChatMessage[]): Promise<string> {
    const httpRequest = http.createHttp()

    try {
      const response = await httpRequest.request(DashScopeUtil.BASE_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${DashScopeUtil.API_KEY}`
        },
        extraData: DashScopeUtil.buildRequestBody(messages, false),
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
   */
  static requestStream(
    messages: ChatMessage[],
    onData: (chunk: string) => void,
    onComplete: () => void,
    onError: (error: string) => void
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
      extraData: DashScopeUtil.buildRequestBody(messages, true),
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
