import { OpenAI } from '@iuroc/openai'
import { ChatCompletionMessageParam } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources'
import { openaiConfig } from '../../../common/config'
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog'

export type ChatDialogMode = '简单总结' | '智能翻译' | '简单解释' | '头脑风暴'

@ComponentV2
export struct ChatDialog {
    @Require @Param messages: Array<ChatCompletionMessageParam>
    @Require @Param model: string
    @Require @Param mode: ChatDialogMode
    @Local resultText: string = ''
    private openai: OpenAI = new OpenAI({
        apiKey: openaiConfig.apiKey,
        baseURL: openaiConfig.baseURL
    })

    aboutToAppear(): void {
        const result = this.openai.chat.completions.create({
            model: this.model,
            messages: this.messages,
            stream: true,
        }, {
            onData: chunks => {
                this.resultText += chunks.map(chunk => chunk.choices[0]?.delta.content).join('')
                this.resultText = replaceChatResult(this.resultText)
            },
            requestConfiguration: {
                security: {
                    remoteValidation: 'skip'
                }
            }
        })
    }

    build() {
        CustomContentDialog({
            contentBuilder: () => {
                this.Content()
            },
            primaryTitle: this.mode,
            contentAreaPadding: {}
        })
    }

    @Builder
    Content() {
        Scroll() {
            Text(this.resultText).width('100%')
                .textAlign(TextAlign.JUSTIFY)
                .wordBreak(WordBreak.BREAK_ALL)
                .padding({ left: 20, right: 20, bottom: 20 })
        }
        .width('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}

function replaceChatResult(text: string) {
    text = text.replaceAll('**', '')
    text = text.replaceAll('```', '')
    text = text.replaceAll(/#+ /g, '')
    return text
}