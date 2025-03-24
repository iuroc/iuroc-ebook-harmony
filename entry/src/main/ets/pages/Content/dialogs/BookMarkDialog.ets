import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog'

@ComponentV2
export struct BookMarkDialog {
    build() {
        CustomContentDialog({
            contentBuilder: () => {
                this.Content()
            },
        })
    }

    @Builder
    Content() {

    }
}

