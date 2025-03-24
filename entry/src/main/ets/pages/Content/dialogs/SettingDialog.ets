import { CustomContentDialog } from '@kit.ArkUI'
import { saveReadSetting, updateWebSetting } from '../util'
import { SettingOptionObservedV2, themeGroup, ThemeGroupItemObservedV2 } from '../WebReadBox'
import { webview } from '@kit.ArkWeb'

@ComponentV2
export struct SettingDialog {
    @Require @Param readSettingOptions: SettingOptionObservedV2
    @Require @Param closeDialog: () => void
    @Require @Param webController: webview.WebviewController

    aboutToAppear(): void {

    }

    build() {
        CustomContentDialog({
            contentBuilder: () => {
                this.Content()
            },
            primaryTitle: '阅读设置',
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
        Scroll() {
            Column({ space: 15 }) {
                Row({ space: 10 }) {
                    Text('主题颜色')
                    Select(themeGroup.map(item => {
                        return {
                            value: item.groupName,
                        } as SelectOption
                    }))
                        .layoutWeight(1)
                        .selectedOptionFontColor(themeGroup[this.readSettingOptions.themeIndex].fontColor)
                        .selectedOptionBgColor(themeGroup[this.readSettingOptions.themeIndex].backgroundColor)
                        .selected(this.readSettingOptions.themeIndex)
                        .onSelect((index, value) => {
                            this.readSettingOptions.themeIndex = index
                            updateWebSetting(this.webController, this.readSettingOptions)
                            saveReadSetting(this.readSettingOptions)
                        })
                        .value(themeGroup[this.readSettingOptions.themeIndex].groupName)
                        .backgroundColor(themeGroup[this.readSettingOptions.themeIndex].backgroundColor)
                        .fontColor(themeGroup[this.readSettingOptions.themeIndex].fontColor)
                }
                .width('100%')
            }
            .width('100%')
        }
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
    }
}