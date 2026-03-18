import { ChatMessage } from '../models/ChatModel'
import { DashScopeUtil } from '../utils/DashScopeUtil'

/**
 * 聊天显示消息（包含 loading 状态）
 */
interface DisplayMessage {
  role: string
  content: string
  isLoading: boolean
}

@Component
export struct AIManager {
  // 对话消息列表（用于展示）
  @State messageList: DisplayMessage[] = []
  // 输入框内容
  @State inputText: string = ''
  // 是否正在请求中
  @State isRequesting: boolean = false
  // 用于滚动控制
  private scroller: Scroller = new Scroller()
  // 历史消息（用于发送给API）
  private chatHistory: ChatMessage[] = []

  aboutToAppear(): void {
    // 添加欢迎消息
    this.messageList.push({
      role: 'assistant',
      content: '你好！我是你的AI智能管家，可以帮你解答财务管理、日常生活等方面的问题。请问有什么可以帮你的吗？',
      isLoading: false
    })
  }

  /**
   * 发送消息
   */
  sendMessage() {
    const content = this.inputText.trim()
    if (content.length === 0 || this.isRequesting) {
      return
    }

    // 1. 添加用户消息到显示列表
    this.messageList.push({
      role: 'user',
      content: content,
      isLoading: false
    })

    // 2. 添加到聊天历史
    const userMsg: ChatMessage = { role: 'user', content: content }
    this.chatHistory.push(userMsg)

    // 3. 清空输入框
    this.inputText = ''
    this.isRequesting = true

    // 4. 添加AI占位消息（loading状态）
    this.messageList.push({
      role: 'assistant',
      content: '',
      isLoading: true
    })

    // 滚动到底部
    this.scrollToBottom()

    // 5. 发起流式请求
    const aiMsgIndex = this.messageList.length - 1
    const historySnapshot: ChatMessage[] = [...this.chatHistory]

    DashScopeUtil.requestStream(
      historySnapshot,
      // onData: 每次收到增量数据
      (chunk: string) => {
        const currentMsg = this.messageList[aiMsgIndex]
        // 使用数组替换触发UI刷新
        this.messageList[aiMsgIndex] = {
          role: 'assistant',
          content: currentMsg.content + chunk,
          isLoading: false
        }
        // 将修改后的数组重新赋值以触发 @State 刷新
        this.messageList = [...this.messageList]
        this.scrollToBottom()
      },
      // onComplete: 流式请求完成
      () => {
        this.isRequesting = false
        // 将AI回复添加到聊天历史
        const finalContent = this.messageList[aiMsgIndex].content
        if (finalContent.length > 0) {
          this.chatHistory.push({ role: 'assistant', content: finalContent })
        }
        this.scrollToBottom()
      },
      // onError: 错误处理
      (error: string) => {
        this.messageList[aiMsgIndex] = {
          role: 'assistant',
          content: `请求出错: ${error}`,
          isLoading: false
        }
        this.messageList = [...this.messageList]
        this.isRequesting = false
      }
    )
  }

  /**
   * 滚动到底部
   */
  scrollToBottom() {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom)
    }, 100)
  }

  /**
   * 清空对话
   */
  clearChat() {
    this.chatHistory = []
    this.messageList = [{
      role: 'assistant',
      content: '对话已清空。有什么可以帮你的吗？',
      isLoading: false
    }]
  }

  build() {
    Column() {
      // ===== 顶部操作栏 =====
      Row() {
        Text('AI智能对话')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        // 清空对话按钮
        Button('清空对话')
          .type(ButtonType.Normal)
          .fontSize(12)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .borderRadius(15)
          .height(30)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.clearChat()
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      // ===== 聊天消息区域 =====
      List({ scroller: this.scroller }) {
        ForEach(this.messageList, (msg: DisplayMessage, index: number) => {
          ListItem() {
            if (msg.role === 'user') {
              // 用户消息 - 靠右
              this.UserBubble(msg)
            } else {
              // AI消息 - 靠左
              this.AIBubble(msg)
            }
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        }, (msg: DisplayMessage, index: number) => `${index}_${msg.content.length}`)
      }
      .width('100%')
      .layoutWeight(1)
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ bottom: 8 })

      // ===== 底部输入区域 =====
      Row({ space: 8 }) {
        // 输入框
        TextInput({ text: this.inputText, placeholder: '输入你的问题...' })
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .borderRadius(20)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value
          })
          .onSubmit(() => {
            this.sendMessage()
          })

        // 发送按钮
        Button() {
          if (this.isRequesting) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(Color.White)
          } else {
            Text('发送')
              .fontSize(14)
              .fontColor(Color.White)
          }
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .backgroundColor(this.inputText.trim().length > 0 && !this.isRequesting ? '#d81e06' : '#CCCCCC')
        .enabled(this.inputText.trim().length > 0 && !this.isRequesting)
        .onClick(() => {
          this.sendMessage()
        })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 12 })
      .backgroundColor(Color.White)
      .border({ width: { top: 0.5 }, color: '#E0E0E0' })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F5F5F5')
  }

  // ===== 用户消息气泡 =====
  @Builder
  UserBubble(msg: DisplayMessage) {
    Row() {
      Blank()
      Column() {
        Text(msg.content)
          .fontSize(14)
          .fontColor(Color.White)
          .lineHeight(22)
          .wordBreak(WordBreak.BREAK_ALL)
      }
      .backgroundColor('#d81e06')
      .borderRadius({
        topLeft: 12,
        topRight: 4,
        bottomLeft: 12,
        bottomRight: 12
      })
      .padding(12)
      .constraintSize({ maxWidth: '75%' })

      // 用户头像
      Column() {
        Text('我')
          .fontSize(12)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor('#d81e06')
      .justifyContent(FlexAlign.Center)
      .margin({ left: 8 })
    }
    .width('100%')
    .justifyContent(FlexAlign.End)
  }

  // ===== AI消息气泡 =====
  @Builder
  AIBubble(msg: DisplayMessage) {
    Row() {
      // AI头像
      Column() {
        Text('AI')
          .fontSize(12)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor('#4A90D9')
      .justifyContent(FlexAlign.Center)
      .margin({ right: 8 })

      Column() {
        if (msg.isLoading && msg.content.length === 0) {
          // 加载中状态
          Row({ space: 4 }) {
            LoadingProgress()
              .width(16)
              .height(16)
              .color('#999999')
            Text('AI正在思考...')
              .fontSize(13)
              .fontColor('#999999')
          }
        } else {
          Text(msg.content)
            .fontSize(14)
            .fontColor('#333333')
            .lineHeight(22)
            .wordBreak(WordBreak.BREAK_ALL)
        }
      }
      .backgroundColor(Color.White)
      .borderRadius({
        topLeft: 4,
        topRight: 12,
        bottomLeft: 12,
        bottomRight: 12
      })
      .padding(12)
      .constraintSize({ maxWidth: '75%' })
      .shadow({
        radius: 4,
        color: 'rgba(0,0,0,0.05)',
        offsetX: 0,
        offsetY: 1
      })

      Blank()
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
}
