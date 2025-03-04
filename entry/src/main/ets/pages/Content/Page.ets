import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { Content } from '../Index/common/lib'
import { getContentAndCatalog, getInfoOnly, makePageHTML } from "./util"
import { webview } from "@kit.ArkWeb"
import { apiOrigin } from "../../common/config"
import { CatalogInInfo, InfoType } from "../Catalog/util"
import { BSColor } from "@iuroc/bootstrap5-color"
import { pasteboard } from "@kit.BasicServicesKit"
import { WebComponent } from "./Test"
import { WebReadBox } from "./WebReadBox"

@ComponentV2
struct Page {
    @Require @Param navTitle: string
    @Event changeNavTitle: (value: string) => void
    @Local contentType: 'book' | 'issue' | null = null
    @Local itemId: number | null = null
    @Local currentBookPage: number = 1
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    webController = new webview.WebviewController()
    /** BookPage 和对应 Content 的映射
     *
     * 正文缓存，如果指定页码的正文存在，则读取缓存，否则就要请求后端返回正文，并存入缓存
     */
    contentMap: Map<number, Content> = new Map()
    /** 目录缓存，只写入一次，后续只要数组不为空就不再写入 */
    @Local catalogs: CatalogInInfo[] = []
    private bookPageCount = 30
    /** 当前正文缓存中的最大页码，每次写入正文缓存，都会更新该值
     *
     * 该值不等于正文 Map 的项目数量，因为正文 Map 初始只是存储了请求页码周期的内容数据
     */
    @Local maxPageNum: number = 0
    /** 该值一旦为 true，则下一页按钮禁用
     *
     * 同时，每次写入正文缓存，都会更新 maxBookPage，当 currentBookPage 等于 maxBookPage 时，也会禁用下一页按钮。
     */
    @Local noMore: boolean = false

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
     *
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
                // 更新当前正文缓存中的最大页码
                this.maxPageNum = Math.max(this.maxPageNum, content.index + 1)
            })
            // 比如设置一次返回 30 页，但是返回的却少于 30 页，这说明已经没有更多页面了，亦或者返回的为空数组，说明上一次获取已经就到底了，这一次也标记为到底了
            if (result.contents.length < this.bookPageCount || result.contents.length == 0) {
                this.noMore = true
            }
        }
        // 比如当前章节的起始页码是 A，那么只要处于当前章节内部，都满足 A <= currentPage，可是上一章节的起始页码 B，也满足 B <= A <= currentPage
        // 所以。取 <= currentPage 的章节的最后一个项目，就是当前的章节。
        this.changeNavTitle(this.catalogs.filter(item => item.page <= this.currentBookPage).slice(-1)[0].title)
        // 将翻页的目标正文载入到 Web 容器
        this.webController.loadData(
            makePageHTML(this.contentMap.get(this.currentBookPage)!.content),
            'text/html', 'utf-8', apiOrigin
        )
    }

    /**
     * 根据当前的 bookPage，获取当前的页码周期起始 bookPage
     *
     * - 例如，每次返回 30 页，那么 currentBookPage 为 1-30，startBookPage 都应该是 1
     * - 例如，每次返回 30 页，那么 currentBookPage 为 31-60，startBookPage 都是 31
     * @param currentBookPage
     * @returns
     */
    getStartBookPageByCurrentBookPage(currentBookPage: number) {
        return Math.floor((currentBookPage - 1) / this.bookPageCount) * this.bookPageCount + 1
    }

    build() {
        RelativeContainer() {
            WebReadBox({
                webController: this.webController,
            }).height('100%')
            this.BottomPanel()
        }
        .width('100%')
        .height('100%')
    }

    @Builder
    BottomPanel() {
        Row({ space: 5 }) {
            Button('上一页')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .fontColor(BSColor.dark)
                .fontSize(15)
                .enabled(this.currentBookPage > 1)
                .onClick(() => {
                    this.changeToPage(--this.currentBookPage)
                })
                .smButton()
            Text(`${this.currentBookPage}/${Math.max(this.catalogs.slice(-1)[0]?.page || 0, this.maxPageNum)}`)
            Button('下一页')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .fontColor(BSColor.dark)
                .fontSize(15)
                .enabled(!this.noMore || this.currentBookPage != this.maxPageNum)
                .onClick(() => {
                    this.changeToPage(++this.currentBookPage)
                })
                .smButton()
        }
        .backgroundColor(Color.White)
        .shadow(ShadowStyle.OUTER_DEFAULT_XS)
        .borderRadius('50%')
        .padding(5)
        .margin(20)
        .alignRules({
            bottom: {
                anchor: '__container__',
                align: VerticalAlign.Bottom,
            },
            right: {
                anchor: '__container__',
                align: HorizontalAlign.End
            }
        })
    }

    @Styles
    smButton() {
        .padding({
            top: 5,
            bottom: 5,
            left: 10,
            right: 10
        })
        .height('auto')
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
        .menus([
            {
                value: '目录',
                action: () => {

                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_square'))
            },
            {
                value: '添加书签',
                action: () => {

                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.bookmark'))
            },
            {
                value: '书刊详情',
                action: () => {

                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.AI_circle_viewfinder'))
            },
            {
                value: '书签列表',
                action: () => {

                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.bookmark'))
            },
            {
                value: '阅读设置',
                action: () => {

                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape'))
            },
            {
                // 统计一些字段的值，比如当前的行间距，字号，背景颜色，历史阅读记录，当前页码，总页码等
                value: '统计信息',
                action: () => {

                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.info_circle'))
            }
        ])
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