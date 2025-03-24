import { ComposeListItem, IconType } from "@ohos.arkui.advanced.ComposeListItem"

@ComponentV2
export struct ToolPanel {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        Scroll() {
            Column() {
                ComposeListItem({
                    contentItem: {
                        iconStyle: IconType.HEAD_SCULPTURE,
                        icon: $r('app.media.ellipsis_message'),
                        primaryText: '智能聊天助手',
                        secondaryText: '接入大模型，开启生成式对话新体验。'
                    }
                })
                    .onClick(() => {
                        this.pathInfos.pushPath({ name: 'Chat' })
                    })
            }
            .padding({
                left: 10,
                right: 10,
                bottom: 10
            })
        }
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .height('100%')
    }
}