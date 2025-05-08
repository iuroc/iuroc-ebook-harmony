import { CustomContentDialog } from '@kit.ArkUI'
import { saveReadSetting, updateWebSetting } from '../util'
import { SettingOptionObservedV2, themeGroup, ThemeGroupItemObservedV2 } from '../WebReadBox'
import { webview } from '@kit.ArkWeb'
import { preferences } from '@kit.ArkData'
import { BSColor } from '@iuroc/bootstrap5-color'

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
            contentAreaPadding: {},
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
                this.ThemeColorSetting()
                this.FontSizeSetting()
                this.LineHeight()
                this.LetterSpaceSetting()
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
        }
        .width('100%')
    }

    @Builder
    FontSizeSetting() {
        Row({ space: 10 }) {
            Text('字体大小')
            Slider({
                min: 14,
                max: 24,
                step: 2,
                style: SliderStyle.InSet,
                value: $$this.readSettingOptions.cssFontSize
            })
                .layoutWeight(1)
                .showSteps(true)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.Moving || mode == SliderChangeMode.Click) {
                        this.updateAndSaveWebSetting()
                    }
                })
                .selectedColor(themeGroup[this.readSettingOptions.themeIndex].mainColor)
            Text(this.readSettingOptions.cssFontSize.toString())
        }
    }

    @Builder
    LetterSpaceSetting() {
        Row({ space: 10 }) {
            Text('字符间距')
            Slider({
                min: 0,
                max: 16,
                step: 2,
                value: this.readSettingOptions.cssLetterSpacing * 10,
                style: SliderStyle.InSet,
            })
                .selectedColor(themeGroup[this.readSettingOptions.themeIndex].mainColor)
                .layoutWeight(1)
                .showSteps(true)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.Moving || mode == SliderChangeMode.Click) {
                        this.readSettingOptions.cssLetterSpacing = value / 10
                        this.updateAndSaveWebSetting()
                    }
                })
            Text(this.readSettingOptions.cssLetterSpacing.toFixed(1).toString())
        }
    }

    @Builder
    LineHeight() {
        Row({ space: 10 }) {
            Text() {
                Span('行').fontColor(Color.Transparent)
                Span('行间距')
            }

            Slider({
                min: 12,
                max: 20,
                step: 2,
                value: this.readSettingOptions.cssLineHeight * 10,
                style: SliderStyle.InSet,
            })
                .selectedColor(themeGroup[this.readSettingOptions.themeIndex].mainColor)
                .layoutWeight(1)
                .showSteps(true)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.Moving || mode == SliderChangeMode.Click) {
                        this.readSettingOptions.cssLineHeight = value / 10
                        this.updateAndSaveWebSetting()
                    }
                })
            Text(this.readSettingOptions.cssLineHeight.toFixed(1).toString())
        }
    }

    @Builder
    ThemeColorSetting() {
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
                    this.updateAndSaveWebSetting()
                })
                .value(themeGroup[this.readSettingOptions.themeIndex].groupName)
                .backgroundColor(themeGroup[this.readSettingOptions.themeIndex].backgroundColor)
                .fontColor(themeGroup[this.readSettingOptions.themeIndex].fontColor)
        }
        .width('100%')
    }

    updateAndSaveWebSetting() {
        updateWebSetting(this.webController, this.readSettingOptions)
        saveReadSetting(this.readSettingOptions)
    }
}