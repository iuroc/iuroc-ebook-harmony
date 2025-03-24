import { CustomContentDialog } from '@kit.ArkUI'

@ComponentV2
export struct SettingDialog {
    build() {
        CustomContentDialog({
            contentBuilder: () => {
                this.Content()
            }
        })
    }

    @Builder
    Content() {

    }
}