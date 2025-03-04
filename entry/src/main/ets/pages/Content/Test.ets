import { webview } from '@kit.ArkWeb'

@ComponentV2
export struct WebComponent {
    controller: webview.WebviewController = new webview.WebviewController()

    aboutToAppear(): void {

    }

    build() {
        Column() {
            Web({ src: $rawfile('readBox.html'), controller: this.controller })
                .onSslErrorEvent(event => {
                    event.handler.handleConfirm()
                })
                .onControllerAttached(() => {

                })
                .editMenuOptions({
                    onCreateMenu: (menuItems: TextMenuItem[]): TextMenuItem[] => {
                        return [
                            {
                                content: '操作',
                                id: new TextMenuItemId()
                            }
                        ]
                    },
                    onMenuItemClick: (menuItem: TextMenuItem, range: TextRange): boolean => {
                        return false
                    }
                })
        }
    }
}