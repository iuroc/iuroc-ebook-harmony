import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog'
import { BookMarkInResponse, toggleBookMark } from '../util'
import { ComposeListItem } from '@ohos.arkui.advanced.ComposeListItem'
import { formatDateChinese } from '../../../common/util'
import { SymbolGlyphModifier } from '@kit.ArkUI'

@ComponentV2
export struct BookMarkDialog {
    @Require @Param bookMarks: BookMarkInResponse[]
    @Require @Param closeDialog: () => void
    @Event changeToPage: (page: number) => Promise<void>

    build() {
        CustomContentDialog({
            contentBuilder: () => {
                this.Content()
            },
            primaryTitle: '书签列表',
            contentAreaPadding: {
                left: 15,
                right: 15,
            },
            buttons: [
                {
                    value: '关闭',
                    action: () => {
                        this.closeDialog()
                    }
                }
            ]
        })
    }

    @Builder
    Content() {
        List() {
            ForEach(this.bookMarks.sort((a, b) => new Date(b.updateAt).getTime() - new Date(a.updateAt).getTime()),
                (item: BookMarkInResponse, index) => {
                    ListItem() {
                        ComposeListItem({
                            contentItem: {
                                primaryText: item.title,
                                secondaryText: new Date(item.updateAt).toLocaleString()
                            },
                            operateItem: {
                                text: `P${item.bookPage}`,
                                icon: {
                                    value: $r('app.media.trash'),
                                    action: () => {
                                        toggleBookMark(item.title, item.bookPage, item.itemId, item.type).then(() => {
                                            this.bookMarks.splice(index, 1)
                                        })
                                    }
                                }
                            }
                        })
                            .onClick(() => {
                                this.changeToPage(item.bookPage)
                                this.closeDialog()
                            })
                    }
                })

        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}