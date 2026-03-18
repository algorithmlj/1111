/**
 * 聊天消息角色类型
 */
export type ChatRole = 'system' | 'user' | 'assistant'

/**
 * 聊天消息模型
 */
export interface ChatMessage {
  role: ChatRole
  content: string
}

/**
 * DashScope API 请求体
 */
export interface DashScopeRequest {
  model: string
  input: DashScopeInput
  parameters: DashScopeParameters
}

export interface DashScopeInput {
  messages: ChatMessage[]
}

export interface DashScopeParameters {
  result_format: string
  incremental_output?: boolean
}

/**
 * DashScope API 响应体
 */
export interface DashScopeResponse {
  output: DashScopeOutput
  usage: DashScopeUsage
  request_id: string
}

export interface DashScopeOutput {
  choices: DashScopeChoice[]
  finish_reason?: string
}

export interface DashScopeChoice {
  finish_reason: string
  message: ChatMessage
}

export interface DashScopeUsage {
  total_tokens: number
  output_tokens: number
  input_tokens: number
}
