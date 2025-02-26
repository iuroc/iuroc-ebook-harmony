import { promptAction } from "@kit.ArkUI"
import { Content } from '../Index/common/lib'
import { getContentAndCatalog, getInfoOnly, makePageHTML } from "./util"
import { webview } from "@kit.ArkWeb"
import { apiOrigin } from "../../common/config"
import { CatalogInInfo, InfoType } from "../Catalog/util"
import { BSColor } from "@iuroc/bootstrap5-color"

@ComponentV2
struct Page {
    @Require @Param navTitle: string
    @Event changeNavTitle: (value: string) => void
    @Local contentType: 'book' | 'issue' | null = null
    @Local itemId: number | null = null
    @Local currentBookPage: number = 1
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    /** BookPage 和对应 Content 的映射 */
    contentMap: Map<number, Content> = new Map()
    catalogs: CatalogInInfo[] = []
    private bookPageCount = 30
    @Local maxPageNum: number = 0
    @Local noMore: boolean = false
    @Local showBottomPanel: boolean = false

    aboutToAppear(): void {
        const param = this.queryNavDestinationInfo()?.param as ContentPageParam | undefined
        if (!param) {
            promptAction.showToast({ message: '页面参数错误' })
            this.pathInfos.pop()
            return
        }

        this.itemId = param.itemId
        this.contentType = param.type
        this.currentBookPage = param.currentBookPage

        this.changeToPage(this.currentBookPage)
    }

    /**
     * 载入指定页码的正文，会自动请求后端数据和处理缓存
     * @param page
     */
    async changeToPage(page: number) {
        if (!this.contentMap.has(page)) {
            // 缓存中没有找到数据，发请求获取
            const result = await getContentAndCatalog(
                this.itemId as number,
                this.contentType as InfoType,
                this.getStartBookPageByCurrentBookPage(this.currentBookPage),
                this.bookPageCount,
                this.catalogs.length == 0  // 如果没有目录缓存，则需要接口返回目录
            )
            // 将目录数据写入缓存
            if (this.catalogs.length == 0 && result.catalogs) {
                this.catalogs = result.catalogs
            }
            // 将获取到的正文写入缓存
            result.contents.forEach(content => {
                this.contentMap.set(content.index + 1, content)
                // 更新最大页码
                this.maxPageNum = Math.max(this.maxPageNum, content.index + 1)
            })
            if (result.contents.length < this.bookPageCount || result.contents.length == 0) {
                this.noMore = true
            }
        }
        this.changeNavTitle(this.catalogs.filter(item => item.page <= this.currentBookPage).slice(-1)[0].title)
        this.webController.loadData(
            makePageHTML(this.contentMap.get(this.currentBookPage)!.content),
            'text/html', 'utf-8', apiOrigin
        )
    }

    getStartBookPageByCurrentBookPage(currentBookPage: number) {
        return Math.floor((currentBookPage - 1) / this.bookPageCount) * this.bookPageCount + 1
    }

    webController = new webview.WebviewController()

    build() {
        RelativeContainer() {
            Scroll() {
                Column() {
                    Web({
                        src: '',
                        controller: this.webController
                    })
                        .width('100%')
                        .onClick(() => {
                            this.showBottomPanel = !this.showBottomPanel
                        })
                        .onScroll(() => {
                            if (this.showBottomPanel) {
                                this.showBottomPanel = false
                            }
                        })
                }
                .width('100%')
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)

            this.BottomPanel()
        }
        .width('100%')
        .height('100%')
    }

    @Builder
    BottomPanel() {
        if (this.showBottomPanel)
        Row({ space: 10 }) {
            Button('上一页').layoutWeight(1).buttonStyle(ButtonStyleMode.NORMAL)
                .onClick(() => {
                    this.changeToPage(--this.currentBookPage)
                })
                .enabled(this.currentBookPage > 1)
            Button('下一页').layoutWeight(1).buttonStyle(ButtonStyleMode.NORMAL)
                .onClick(() => {
                    this.changeToPage(++this.currentBookPage)
                })
                .enabled(!this.noMore || this.currentBookPage != this.maxPageNum)
        }
        .width('100%')
        .id('bottomPanel')
        .alignRules({
            bottom: {
                anchor: '__container__',
                align: VerticalAlign.Bottom
            }
        })
        .backgroundColor(BSColor.white)
        .padding(15)
    }
}

@ComponentV2
struct PageNav {
    @Local navTitle: string = ''

    build() {
        NavDestination() {
            Page({
                navTitle: this.navTitle,
                changeNavTitle: value => {
                    this.navTitle = value
                }
            })
        }
        .title(this.navTitle)
    }
}

@Builder
export function PageBuilder() {
    PageNav()
}

export interface ContentPageParam {
    type: 'book' | 'issue'
    /** bookId 或 issueId */
    itemId: number
    /** 书刊页码，从 1 开始 */
    currentBookPage: number
}