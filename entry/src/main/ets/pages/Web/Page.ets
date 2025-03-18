import { webview } from "@kit.ArkWeb"
import { promptAction } from "@kit.ArkUI"

@ComponentV2
struct Page {
    private controller: webview.WebviewController = new webview.WebviewController()
    @Local navTitle: string = ''
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    aboutToAppear(): void {

    }

    build() {
        NavDestination() {
            Web({
                src: '',
                controller: this.controller
            })
                .onSslErrorEvent(event => {
                    event.handler.handleConfirm()
                })
                .onControllerAttached(() => {
                    const params = this.pathInfos.getParamByName('Web') as Object[]
                    if (!params[0]) {
                        this.pathInfos.pop()
                        promptAction.showToast({ message: '页面参数不完整' })
                    }

                    const param = params[0] as WebPageParam
                    this.controller.loadUrl(param.src)
                })
                .onProgressChange(event => {
                    this.navTitle = this.controller.getTitle()
                })
        }
        .title(this.navTitle)
    }
}

@ComponentV2
struct XXX {
    aboutToAppear(): void {
        console.log(JSON.stringify(this.queryNavDestinationInfo()))
    }

    build() {
    }
}

@Builder
export function PageBuilder() {
    Page()
}

export interface WebPageParam {
    src: string
}