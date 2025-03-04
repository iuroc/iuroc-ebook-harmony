import { webview } from '@kit.ArkWeb'

@ComponentV2
export struct WebReadBox {
    @Require @Param webController: webview.WebviewController

    build() {
        Web({ src: '', controller: this.webController })
            .overScrollMode(OverScrollMode.ALWAYS)
            .width('100%')
            .selectionMenuOptions([
                {
                    content: '简单总结',
                    action: text => {

                    }
                },
                {
                    content: '智能翻译',
                    action: text => {

                    }
                },
                {
                    content: '简单解释',
                    action: text => {

                    }
                },
                {
                    content: '分享文本',
                    action: text => {

                    }
                },
                {
                    content: '百科搜索',
                    action: text => {

                    }
                },
                {
                    content: '添加摘录',
                    action: text => {

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
}
