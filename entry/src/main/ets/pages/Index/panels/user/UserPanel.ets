import { clearUserPreferences } from '../../../../common/token'
import { ComposeListItem, IconType } from '@ohos.arkui.advanced.ComposeListItem'
import { BSColor } from '@iuroc/bootstrap5-color'
import { deleteUser } from './utils'
import { IconStyle, promptAction } from '@kit.ArkUI'
import { systemShareTextWithToast } from '@iuroc/chat-page'

@ComponentV2
export struct UserPanel {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        List() {
            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '阅读笔记',
                        secondaryText: '包含您的阅读摘录和个人笔记',
                        iconStyle: IconType.SYSTEM_ICON,
                        icon: $r('app.media.note_blue')
                    }
                })
                    .onClick(() => {
                        this.pathInfos.pushPath({ name: 'Note' })
                    })
            }

            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '阅读历史',
                        secondaryText: '查看您看过的书',
                        iconStyle: IconType.SYSTEM_ICON,
                        icon: $r('app.media.share')
                    }
                })
                    .onClick(() => {
                        this.pathInfos.pushPath({ name: 'History' })
                    })
            }

            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '退出登录',
                        secondaryText: '您的云端数据不会被删除',
                        iconStyle: IconType.SYSTEM_ICON,
                        icon: $r('app.media.logout')
                    }
                }).onClick(() => {
                    AlertDialog.show({
                        title: '退出登录',
                        message: '确定要退出登录吗？（你的云端数据不会被删除）',
                        buttons: [
                            {
                                value: '确定退出',
                                fontColor: BSColor.danger,
                                action: () => {
                                    clearUserPreferences().then(() => {
                                        this.pathInfos.pushPath({ name: 'Login' }, false)
                                    })
                                }
                            },
                            {
                                value: '取消',
                                fontColor: BSColor.dark,
                                action: () => {

                                }
                            }
                        ]
                    })
                })
            }

            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '注销账号',
                        secondaryText: '彻底删除您的账号和云端数据',
                        iconStyle: IconType.SYSTEM_ICON,
                        icon: $r('app.media.delete_user')
                    }
                }).onClick(() => {
                    AlertDialog.show({
                        title: '注销账号',
                        message: '确定要注销账号吗？（这是一个危险操作，你的云端数据将被删除）',
                        buttons: [
                            {
                                value: '确定注销',
                                fontColor: BSColor.danger,
                                action: () => {
                                    deleteUser().then(() => {
                                        this.pathInfos.pushPath({ name: 'Login' }, false)
                                    }).catch((error: Error) => {
                                        promptAction.showToast(error)
                                    })
                                }
                            },
                            {
                                value: '取消',
                                fontColor: BSColor.dark,
                                action: () => {

                                }
                            }
                        ]
                    })
                })
            }

            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '分享应用',
                        iconStyle: IconType.SYSTEM_ICON,
                        icon: $r('app.media.share')
                    }
                }).onClick(() => {
                    systemShareTextWithToast('分享应用 EBOOK', `📖 EBOOK —— 免费阅读，智能陪伴！
海量图书 & 期刊，免费畅享阅读 📚✨
AI智能助理，帮你解读内容、生成摘要、互动问答 🤖💡
快来体验吧！📲 下载链接：https://www.iuroc.com`)
                })
            }

            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '关于应用',
                        iconStyle: IconType.SYSTEM_ICON,
                        icon: $r('app.media.info_circle')
                    }
                }).onClick(() => {
                    promptAction.showDialog({
                        title: '关于应用',
                        message: `EBOOK 是一款智能阅读软件，汇聚海量 📚 图书 & 期刊，结合 AI 大模型，为你带来更高效、更便捷的阅读体验。  

✨ 自由阅读：提供丰富的书籍与期刊，涵盖文学、科技、历史、财经等多个领域，全部免费畅享。  
📖 智能阅读器：支持目录导航、书签、笔记，正文可包含插图，排版精美，带来沉浸式阅读体验。  
🤖 AI 助手：提供摘要生成、内容解释、翻译服务、智能对话，助你更快理解书籍内容。  
📂 个性化书架：收藏喜欢的书籍，记录阅读进度，打造你的专属图书馆。  

🚀 让阅读更智能，让知识触手可及！  

🔗 项目开源地址：https://github.com/iuroc/iuroc-ebook-harmony`,
                        buttons: [
                            {
                                text: '确定',
                                color: BSColor.success
                            }
                        ]
                    })
                })
            }
        }
        .padding({ left: 10, right: 10, bottom: 10 })
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}