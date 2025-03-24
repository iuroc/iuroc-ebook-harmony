import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { Content } from '../Index/common/lib'
import {
    BookMarkInResponse,
    getBookMarks,
    getCatalogTitleByBookPage,
    getContentAndCatalog,
    loadReadSetting,
    makePageHTML,
    toggleBookMark,
    updateReadHistory
} from "./util"
import { webview } from "@kit.ArkWeb"
import { apiOrigin } from "../../common/config"
import { CatalogInInfo, InfoType, IssueInfoNoCatalogsInResponse } from "../Catalog/util"
import { BSColor } from "@iuroc/bootstrap5-color"
import { SettingOptionObservedV2, themeGroup, WebReadBox } from "./WebReadBox"
import { CatalogDialog } from "./dialogs/CatalogDialog"
import { BookListItemInResponse } from "../Index/common/mixin"
import { BookMarkDialog } from "./dialogs/BookMarkDialog"
import { SettingDialog } from "./dialogs/SettingDialog"

@ComponentV2
struct Page {
    private webController = new webview.WebviewController()
    private bookPageCount = 30
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local contentType: 'book' | 'issue' | null = null
    @Local itemId: number | null = null
    @Local navTitle: string = ''
    @Local currentBookPage: number = 1
    /** 是否正在翻页的过程中，该值为 true 时，翻页按钮禁用 */
    @Local isRequestingPage: boolean = false
    /** BookPage 和对应 Content 的映射
     *
     * 正文缓存，如果指定页码的正文存在，则读取缓存，否则就要请求后端返回正文，并存入缓存 */
    @Local contentMap: Map<number, Content> = new Map()
    /** 目录缓存，只写入一次，后续只要数组不为空就不再写入 */
    @Local catalogs: CatalogInInfo[] = []
    /**
     * 当前书刊的书签列表的 Book 页码序列
     */
    @Local bookMarks: BookMarkInResponse[] = []
    @Local readSettingOptions: SettingOptionObservedV2 = loadReadSetting()
    /** 当前正文缓存中的最大页码，每次写入正文缓存，都会更新该值
     *
     * 该值不等于正文 Map 的项目数量，因为正文 Map 初始只是存储了请求页码周期的内容数据 */
    @Local maxPageNum: number = 0
    /** 该值一旦为 true，则下一页按钮禁用
     *
     * 同时，每次写入正文缓存，都会更新 maxBookPage，当 currentBookPage 等于 maxBookPage 时，也会禁用下一页按钮。 */
    @Local noMore: boolean = false
    private catalogDialogId: number = 0
    private bookMarkDialogId: number = 0
    private settingDialogId: number = 0
    /** 当前阅读内容所属的图书或期刊的详情 */
    @Local itemInfo: IssueInfoNoCatalogsInResponse | BookListItemInResponse | null = null

    aboutToAppear(): void {
        const param = this.pathInfos.getParamByName('Content')[0] as ContentPageParam | undefined
        // const param = this.queryNavDestinationInfo()?.param as ContentPageParam | undefined
        if (!param) {
            promptAction.showToast({ message: '页面参数错误' })
            this.pathInfos.pop()
            return
        }

        this.itemId = param.itemId
        this.contentType = param.type
        this.currentBookPage = param.currentBookPage

        getBookMarks(this.itemId, this.contentType, 0, 240).then(result => {
            result.forEach(item => {
                this.bookMarks.push(item)
            })
        }).catch((error: Error) => {
            promptAction.showToast(error)
        })
    }

    /**
     * 载入指定页码的正文，会自动请求后端数据和处理缓存
     *
     * @param page
     */
    async changeToPage(page: number): Promise<void> {
        this.isRequestingPage = true
        if (!this.contentMap.has(page)) {
            // 缓存中没有找到数据，发请求获取
            const result = await getContentAndCatalog(
                this.itemId as number,
                this.contentType as InfoType,
                this.getStartBookPageByCurrentBookPage(page),
                this.bookPageCount,
                this.catalogs.length == 0  // 如果没有目录缓存，则需要接口返回目录
            )
            this.itemInfo = result.info
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
        this.navTitle = getCatalogTitleByBookPage(page, this.catalogs)
        // 将翻页的目标正文载入到 Web 容器
        this.webController.loadData(
            makePageHTML(this.contentMap.get(page)!.content, this.readSettingOptions),
            'text/html', 'utf-8', apiOrigin
        )
        await updateReadHistory(this.itemId as number, this.contentType as InfoType, page)
        this.isRequestingPage = false
        this.currentBookPage = page
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

    bookMarkIcon() {
        if (this.bookMarks.find(item => item.bookPage == this.currentBookPage)) {
            return new SymbolGlyphModifier($r('sys.symbol.bookmark_fill')).fontColor([BSColor.warning])
        } else {
            return new SymbolGlyphModifier($r('sys.symbol.bookmark'))
        }
    }

    build() {
        NavDestination() {
            RelativeContainer() {
                WebReadBox({
                    webController: this.webController,
                    itemInfo: this.itemInfo as IssueInfoNoCatalogsInResponse | BookListItemInResponse,
                    currentBookPage: this.currentBookPage,
                    contentType: this.contentType as 'book' | 'issue',
                    readSettingOptions: this.readSettingOptions,
                    changeToPage: page => this.changeToPage(page),
                }).height('100%')
                this.BottomPanel()
            }
            .width('100%')
            .height('100%')
        }
        .onBackPressed(() => {
            this.pathInfos.pop({
                currentBookPage: this.currentBookPage
            } as ContentPagePopResult)
            return true
        })
        .title(this.navTitle)
        .menus([
            {
                value: '目录',
                action: () => {
                    promptAction.openCustomDialog({
                        builder: () => {
                            this.CatalogDialog()
                        }
                    }).then(id => this.catalogDialogId = id)
                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_square'))
            },
            {
                value: '添加书签',
                action: () => {
                    toggleBookMark(this.navTitle, this.currentBookPage, this.itemId, this.contentType).then(result => {
                        if (result) {
                            this.bookMarks.push(result)
                        } else {
                            this.bookMarks = this.bookMarks.filter(i => i.bookPage != this.currentBookPage)
                        }
                    }).catch((error: Error) => {
                        promptAction.showToast(error)
                    })
                },
                symbolIcon: this.bookMarkIcon()
            },
            {
                value: '书刊详情',
                action: () => {
                    this.pathInfos.popToName('Catalog', {
                        currentBookPage: this.currentBookPage
                    } as ContentPagePopResult)
                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.AI_circle_viewfinder'))
            },
            {
                value: '书签列表',
                isEnabled: this.bookMarks.length > 0,
                action: () => {
                    promptAction.openCustomDialog({
                        builder: () => {
                            this.BookMarkDialog()
                        },
                    }).then(id => this.bookMarkDialogId = id)
                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.bookmark'))
            },
            {
                value: '阅读设置',
                action: () => {
                    promptAction.openCustomDialog({
                        builder: () => {
                            this.SettingDialog()
                        }
                    }).then(id => this.settingDialogId = id)
                },
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.gearshape'))
            },
        // {
        //     // 统计一些字段的值，比如当前的行间距，字号，背景颜色，历史阅读记录，当前页码，总页码等
        //     value: '统计信息',
        //     action: () => {
        //
        //     },
        //     symbolIcon: new SymbolGlyphModifier($r('sys.symbol.info_circle'))
        // }
        ])
        .backgroundColor(themeGroup[this.readSettingOptions.themeIndex].backgroundColor)
    }

    @Builder
    CatalogDialog() {
        CatalogDialog({
            catalogs: this.catalogs,
            currentBookPage: this.currentBookPage,
            changeToPage: page => this.changeToPage(page),
            close: () => promptAction.closeCustomDialog(this.catalogDialogId)
        })
    }

    @Builder
    SettingDialog() {
        SettingDialog({
            readSettingOptions: this.readSettingOptions,
            webController: this.webController,
            closeDialog: () => {
                promptAction.closeCustomDialog(this.settingDialogId)
            }
        })
    }

    @Builder
    BookMarkDialog() {
        BookMarkDialog({
            bookMarks: this.bookMarks,
            changeToPage: page => this.changeToPage(page),
            closeDialog: () => {
                promptAction.closeCustomDialog(this.bookMarkDialogId)
            }
        })
    }

    @Builder
    BottomPanel() {
        Row({ space: 5 }) {
            Button('上一页')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .fontColor(BSColor.dark)
                .fontSize(15)
                .enabled(this.currentBookPage > 1 && !this.isRequestingPage)
                .onClick(() => {
                    this.changeToPage(this.currentBookPage - 1)
                })
                .smButton()
            Text(`${this.currentBookPage}/${Math.max(this.catalogs.slice(-1)[0]?.page || 0, this.maxPageNum)}`)
            Button('下一页')
                .buttonStyle(ButtonStyleMode.NORMAL)
                .fontColor(BSColor.dark)
                .fontSize(15)
                .enabled(!this.noMore || this.currentBookPage != this.maxPageNum && !this.isRequestingPage)
                .onClick(() => {
                    this.changeToPage(this.currentBookPage + 1)
                })
                .smButton()
        }
        .backgroundColor(themeGroup[this.readSettingOptions.themeIndex].backgroundColor)
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


@Builder
export function PageBuilder() {
    Page()
}

export interface ContentPageParam {
    type: 'book' | 'issue'
    /** bookId 或 issueId */
    itemId: number
    /** 书刊页码，从 1 开始 */
    currentBookPage: number
}

export interface ContentPagePopResult {
    currentBookPage: number
}
