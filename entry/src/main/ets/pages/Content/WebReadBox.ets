import { webview } from '@kit.ArkWeb'
import { promptAction } from '@kit.ArkUI'
import { ChatDialog, ChatDialogMode } from './dialogs/Chat'
import { ChatCompletionMessageParam } from '@iuroc/openai/src/main/ets/openai@4.73.1/resources'
import { systemShareTextWithToast } from './util'
import { WebPageParam } from '../Web/Page'
import { url } from '@kit.ArkTS'
import { createNote } from '../Note/utils'
import { IssueInfoNoCatalogsInResponse } from '../Catalog/util'
import { BookListItemInResponse } from '../Index/common/mixin'

@ComponentV2
export struct WebReadBox {
    @Require @Param webController: webview.WebviewController
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    /** 当前阅读内容所属的图书或期刊的详情 */
    @Require @Param itemInfo: IssueInfoNoCatalogsInResponse | BookListItemInResponse
    @Require @Param currentBookPage: number
    @Require @Param contentType: 'book' | 'issue'

    build() {
        Web({ src: '', controller: this.webController })
            .overScrollMode(OverScrollMode.ALWAYS)
            .width('100%')
            .selectionMenuOptions([
                {
                    content: '简单总结',
                    action: text => {
                        promptAction.openCustomDialog({
                            builder: () => {
                                this.ChatDialog('gpt-4o-mini', [
                                    {
                                        role: 'user',
                                        content: `请你用最通俗易懂的文字总结下面的内容：${text}`
                                    }
                                ], '简单总结')
                            }
                        })
                    }
                },
                {
                    content: '智能翻译',
                    action: text => {
                        promptAction.openCustomDialog({
                            builder: () => {
                                this.ChatDialog('gpt-4o-mini', [
                                    {
                                        role: 'system',
                                        content: '你是翻译专家，如果用户给你的是中文，则你将其翻译为英文。如果是非中文，则一律翻译为中文。'
                                    },
                                    {
                                        role: 'user',
                                        content: `${text}`
                                    }
                                ], '智能翻译')
                            },
                        })
                    }
                },
                {
                    content: '简单解释',
                    action: text => {
                        promptAction.openCustomDialog({
                            builder: () => {
                                this.ChatDialog('gpt-4o-mini', [
                                    {
                                        role: 'user',
                                        content: `用户无法理解下面的内容，请你做出简单的解释：${text}`
                                    }
                                ], '简单解释')
                            },
                        })
                    }
                },
                {
                    content: '头脑风暴',
                    action: text => {
                        promptAction.openCustomDialog({
                            builder: () => {
                                this.ChatDialog('gpt-4o-mini', [
                                    {
                                        role: 'user',
                                        content: `请你针对下面的内容生成5个头脑风暴：${text}`
                                    }
                                ], '头脑风暴')
                            },
                        })
                    }
                },
                {
                    content: '分享文本',
                    action: text => {
                        systemShareTextWithToast('分享文本', text as Object as string)
                    }
                },
                {
                    content: '百科搜索',
                    action: text => {
                        this.pathInfos.pushPath({
                            name: 'Web', param: {
                                src: `https://baike.baidu.com/lemma/api/entry?word=${encodeURIComponent(text as Object as string)}`
                            } as WebPageParam
                        })
                    }
                },
                {
                    content: '添加摘录',
                    action: text => {
                        createNote('阅读摘录',
                            `摘录自《${this.contentType == 'issue' ?
                                (this.itemInfo as IssueInfoNoCatalogsInResponse).magazine.name + ' - ' :
                                ''}${this.itemInfo.name}》第 ${this.currentBookPage} 页\n\n${text}`)
                            .then(() => {
                                promptAction.showToast({ message: '添加摘录成功' })
                            })
                            .catch((error: Error) => {
                                promptAction.showToast({ message: '添加摘录失败' })
                            })
                    }
                },
            ])
    }

    @Builder
    Menu() {
        Menu() {
            MenuItem() {
                Text('操作')
            }
        }
    }

    @Builder
    ChatDialog(model: string, messages: ChatCompletionMessageParam[], mode: ChatDialogMode) {
        ChatDialog({
            model: model,
            messages: messages,
            mode: mode
        })
    }
}
