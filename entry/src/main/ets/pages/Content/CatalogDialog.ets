import { BSColor } from '@iuroc/bootstrap5-color'
import { CatalogInInfo } from '../Catalog/util'
import { CustomContentDialog } from '@ohos.arkui.advanced.Dialog'

@ComponentV2
export struct CatalogDialog {
    @Require @Param catalogs: CatalogInInfo[]
    @Require @Param currentBookPage: number
    @Event changeToPage: (page: number) => Promise<void>
    @Require @Param close: () => void
    scroller = new Scroller()
    @Local activeIndex: number = 0

    aboutToAppear(): void {
        this.activeIndex = this.getActiveIndex()
    }

    build() {
        CustomContentDialog({
            contentBuilder: () => {
                this.Content()
            },
            contentAreaPadding: {},
            primaryTitle: '书刊目录'
        })
    }

    @Builder
    Content() {
        Scroll(this.scroller) {
            Column() {
                ForEach(this.catalogs, (catalog: CatalogInInfo, index) => {
                    Row({ space: 10 }) {
                        if (catalog.hasChild) {
                            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill')).fontColor([BSColor.secondary])
                        }
                        Text(catalog.title)
                    }
                    .width('100%')
                    .padding({
                        top: 10,
                        bottom: 10,
                        right: 15,
                        left: 15 + catalog.level * 35
                    })
                    .borderRadius(10)
                    .stateStyles({
                        pressed: {
                            .backgroundColor(BSColor.secondary_bg_subtle)
                        },
                        normal: {
                            .backgroundColor(index == this.activeIndex ? BSColor.success_bg_subtle : Color.Transparent)
                        }
                    })
                    .onClick(() => {
                        this.changeToPage(catalog.page)
                        this.close()
                    })
                })
            }
            .width('100%')
            .padding({
                bottom: 50,
                left: 10,
                right: 10
            })
            .onAreaChange((oldValue, newValue) => {
                if ((newValue.width as number) - (oldValue.width as number) > 0) {
                    this.scroller.scrollTo({
                        xOffset: 0,
                        yOffset: this.scroller.getItemRect(0).height * (this.activeIndex / this.catalogs.length) - 100
                    })
                }
            })
        }
        .align(Alignment.Top)
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }

    getActiveIndex(): number {
        for (let i = 0; i < this.catalogs.length; i++) {
            if (this.currentBookPage >= this.catalogs[i].page && (!this.catalogs[i + 1] ||
                this.catalogs[i + 1].page > this.currentBookPage)) {
                return i
            }
        }
        return 1
    }
}