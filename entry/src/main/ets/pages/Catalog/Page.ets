import {
    BookInfoInResponse,
    CatalogInInfo,
    CatalogObservedV2,
    getInfo,
    getOneBookShelf,
    getOneReadHistory,
    InfoType,
    IssueInfoInResponse,
    toggleBookShelf,
} from './util'
import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { Catalog } from '../Index/common/lib'
import { MagazineListItem } from '../Index/panels/magazine/MagazinePanel'
import { apiOrigin } from '../../common/config'
import { BSColor } from '@iuroc/bootstrap5-color'
import { extname, extToMime, getPreviewFileUriForImageURL, replaceChinesePunctuation } from '../../common/util'
import { filePreview } from '@kit.PreviewKit'
import { ContentPageParam, ContentPagePopResult } from '../Content/Page'
import { getCatalogTitleByBookPage } from '../Content/util'
import { MainPagePopParam } from '../Index/Page'

@ComponentV2
struct FieldRow {
    @Param label?: string = undefined
    @Require @Param content: string
    @Param replaceChinesePunctuation: boolean = true
    @Param fontColor?: ResourceColor = undefined

    build() {
        Text() {
            if (this.label) {
                Span(this.label + '：').fontColor(BSColor.secondary)
            }
            Span(this.replaceChinesePunctuation ? replaceChinesePunctuation(this.content) : this.content)
                .fontColor(this.fontColor)
        }
        .fontSize(14)
        .width('100%')
        .fontWeight(FontWeight.Normal)
        .maxLines(1)
        .textAlign(TextAlign.JUSTIFY)
        .wordBreak(WordBreak.BREAK_ALL)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
}

@ComponentV2
struct Page {
    @Event changeNavTitle: (title: string) => void
    /**
     * Book 或 Issue 的 ID
     */
    @Local itemId?: number
    /**
     * 数据类型，Book 或 Issue
     */
    @Local type?: InfoType
    @Local cover: string = ''
    @Local bookInfo?: BookInfoObservedV2
    @Local issueInfo?: IssueInfoInObservedV2
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Event changeIsInBookShelf: (value: boolean | null) => void
    /**
     * 是否已在书架
     */
    @Require @Param isInBookShelf: boolean | null
    /** 当前读到第几页了 */
    @Local currentBookPage: number | null = null

    aboutToAppear(): void {
        const param = this.queryNavDestinationInfo()?.param
        if (param) {
            this.itemId = (param as CatalogPageParam).itemId
            this.type = (param as CatalogPageParam).type
            Promise.all([
            // 加载书刊信息
                getInfo(this.itemId as number, this.type as InfoType).then(result => {
                    if (this.type == 'book') {
                        this.bookInfo = new BookInfoObservedV2(result as BookInfoInResponse)
                        this.changeNavTitle('图书详情')
                    } else if (this.type == 'issue') {
                        this.issueInfo = new IssueInfoInObservedV2(result as IssueInfoInResponse)
                        this.changeNavTitle('期刊详情')
                    }
                }),
                // 判断是否在书架中
                getOneBookShelf(this.itemId as number, this.type as InfoType).then(result => {
                    this.changeIsInBookShelf(!!result)
                }),
                // 获取当前阅读进度，用于在目录中高亮显示
                getOneReadHistory(this.itemId as number, this.type as InfoType).then(result => {
                    this.currentBookPage = result && result.currentBookPage || 1
                })
            ]).catch((error: Error) => {
                promptAction.showToast(error)
            })
        }
    }

    build() {
        Scroll() {
            Column({ space: 15 }) {
                this.NavCard()
                this.ContinueRead()
                this.Summary()
                this.CatalogList()
            }
            .width('100%')
            .padding({ top: 15, bottom: 15 })
        }
        .height('100%')
        .width('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }

    @Builder
    ContinueRead() {
        if ((this.currentBookPage || 1) > 1) {
            Column() {
                Row() {
                    Text() {
                        Span('继续阅读：')
                        Span(getCatalogTitleByBookPage(this.currentBookPage || 1,
                            (this.type == 'book' ? this.bookInfo?.catalogs :
                                this.issueInfo?.catalogs) as CatalogInInfo[]))
                            .fontWeight(FontWeight.Bold)
                    }
                    .fontColor(BSColor.warning_text_emphasis)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('100%')
                .padding({
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10
                })
                .border({
                    width: 1,
                    color: BSColor.warning_border_subtle,
                })
                .backgroundColor(BSColor.warning_bg_subtle)
                .borderRadius(10)
                .onClick(() => {
                    this.gotoContentPage()
                })
            }
            .width('100%')
            .padding({ left: 10, right: 10 })
        }
    }

    @Builder
    CatalogList() {
        Row({ space: 5 }) {
            SymbolGlyph($r('sys.symbol.list_bullet_circle'))
                .fontColor([BSColor.primary_text_emphasis])
            Text('目录')
                .fontWeight(FontWeight.Bold)
                .fontColor(BSColor.primary_text_emphasis)
        }
        .width('100%')
        .padding({ left: 15, right: 15 })


        Column() {
            Column() {
                ForEach(this.type == 'book' ? this.bookInfo?.catalogs : this.issueInfo?.catalogs,
                    (catalog: CatalogInInfo, index) => {
                        Row({ space: 10 }) {
                            if (catalog.level > 0) {
                                Divider()
                                    .vertical(true)
                                    .height(30)
                                    .margin({ left: catalog.level * 20 })
                            }
                            Column({ space: 5 }) {
                                Text(catalog.title)
                                    .fontWeight(catalog.level == 0 ? FontWeight.Bold : FontWeight.Normal)
                                    .textAlign(TextAlign.JUSTIFY)
                                    .wordBreak(WordBreak.BREAK_ALL)
                                    .maxLines(1)
                                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                                    .fontColor(catalog.page == null ? BSColor.secondary :
                                        (catalog.level == 0 ? BSColor.secondary_text_emphasis : BSColor.secondary))
                                    .width('100%')
                            }
                            .layoutWeight(1)
                            .padding({ top: 10, bottom: 10 })
                        }
                        .stateStyles({
                            pressed: {
                                .backgroundColor(catalog.page == null ? undefined : BSColor.secondary_bg_subtle)
                            },
                            normal: {
                                .backgroundColor(Color.Transparent)
                            }
                        })
                        .padding({ left: 15, right: 15 })
                        .onClick(() => {
                            if (catalog.page != null) {
                                this.currentBookPage = catalog.page
                                this.gotoContentPage()
                            }
                        })
                    })
            }
            .backgroundColor(BSColor.light)
            .borderRadius(10)
            .padding({ top: 10, bottom: 10 })
        }
        .width('100%')
        .padding({ left: 5, right: 5 })
    }

    @Builder
    Summary() {
        Column() {
            Column({ space: 10 }) {
                Row({ space: 5 }) {
                    SymbolGlyph($r('sys.symbol.info_circle')).fontSize(18).fontColor([BSColor.primary_text_emphasis])
                    Text((this.type == 'book' ? '图书' : '期刊') + '内容简介')
                        .fontWeight(FontWeight.Bold)
                        .width('100%')
                        .fontColor(BSColor.primary_text_emphasis)
                }

                Text(this.type == 'book' ? this.bookInfo?.summary : this.issueInfo?.magazine.summary)
                    .wordBreak(WordBreak.BREAK_ALL)
                    .textAlign(TextAlign.JUSTIFY)
                    .width('100%')
                    .fontWeight(FontWeight.Normal)
                    .letterSpacing(1)
                    .lineSpacing(LengthMetrics.vp(4))
                    .fontSize(14)
            }
            .width('100%')
            .padding(15)
            .backgroundColor(BSColor.light)
            .borderRadius(15)
        }
        .width('100%')
        .padding({ left: 5, right: 5 })
    }

    getCover(useBig: boolean) {
        return apiOrigin + (this.type == 'book'
            ? (useBig ? this.bookInfo?.bigCover : this.bookInfo?.cover)
            : this.issueInfo?.cover)
    }

    @Builder
    NavCard() {
        Row({ space: 15 }) {
            Column({ space: 15 }) {
                Text(this.type == 'book' ? this.bookInfo?.name : this.issueInfo?.magazine.name)
                    .fontWeight(FontWeight.Bold)
                    .width('100%')
                    .maxLines(1)
                    .textAlign(TextAlign.JUSTIFY)
                    .wordBreak(WordBreak.BREAK_ALL)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Column({ space: 10 }) {
                    if (this.type == 'book') {
                        FieldRow({
                            label: '作者',
                            content: this.bookInfo?.author,
                            fontColor: BSColor.info_text_emphasis
                        })
                        FieldRow({
                            label: '出版单位',
                            content: this.bookInfo?.publish,
                            fontColor: BSColor.success_text_emphasis
                        })
                        FieldRow({
                            label: 'ISBN',
                            content: this.bookInfo?.isbn,
                            fontColor: BSColor.primary_text_emphasis
                        })
                    } else if (this.type == 'issue') {
                        FieldRow({
                            content: this.issueInfo?.name,
                            fontColor: BSColor.info_text_emphasis
                        })
                        FieldRow({
                            label: 'CN',
                            content: this.issueInfo?.magazine.cn,
                            fontColor: BSColor.success_text_emphasis
                        })
                        FieldRow({
                            label: 'ISSN',
                            content: this.issueInfo?.magazine.issn,
                            fontColor: BSColor.primary_text_emphasis
                        })
                    }
                }

                Row({ space: 5 }) {
                    Button('开始阅读').layoutWeight(1)
                        .enabled(this.currentBookPage != null)
                        .onClick(() => {
                            this.currentBookPage = 1
                            this.gotoContentPage()
                        })
                    Button(this.isInBookShelf ? '已在书架' : '加到书架')
                        .enabled(this.isInBookShelf != null)
                        .backgroundColor(
                            this.isInBookShelf ? BSColor.success_bg_subtle : BSColor.secondary_bg_subtle
                        )
                        .fontColor(
                            this.isInBookShelf ? BSColor.success_text_emphasis : BSColor.secondary_text_emphasis
                        )
                        .layoutWeight(1)
                        .onClick(() => {
                            this.changeIsInBookShelf(null)
                            toggleBookShelf(this.itemId as number, this.type as InfoType).then(result => {
                                this.changeIsInBookShelf(result.isInBookShelf)
                            }).catch((error: Error) => {
                                promptAction.showToast(error)
                            })
                        })
                }
                .width('100%')
            }
            .layoutWeight(1)

            Image(this.getCover(false))
                .height(160)
                .width(100 * 150 / 140)
                .shadow(ShadowStyle.OUTER_DEFAULT_XS)
                .borderRadius(10)
                .onClick(() => {
                    const imageURL = this.getCover(true)
                    getPreviewFileUriForImageURL(imageURL).then(uri => {
                        filePreview.openPreview(getContext(), {
                            uri,
                            title: '预览' + (this.type == 'book' ? '图书' : '期刊') + '封面',
                            mimeType: extToMime(extname(imageURL))[0]
                        })
                    })
                })
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({
            left: 15,
            right: 15
        })
    }

    /** 请先修改 `this.currentBookPage`，然后调用本方法，跳转到阅读页面 */
    gotoContentPage() {
        this.pathInfos.pushPath({
            name: 'Content', param: {
                type: this.type,
                itemId: this.itemId,
                currentBookPage: this.currentBookPage,
            } as ContentPageParam,
            onPop: info => {
                const result = info.result as ContentPagePopResult
                // 更新阅读进度
                this.currentBookPage = result.currentBookPage
            }
        })
    }
}

@ComponentV2
struct PageNav {
    @Local navTitle: string = ''
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local isInBookShelf: boolean | null = null

    build() {
        NavDestination() {
            Page({
                changeNavTitle: title => {
                    this.navTitle = title
                },
                isInBookShelf: this.isInBookShelf,
                changeIsInBookShelf: value => {
                    this.isInBookShelf = value
                }
            })
        }
        .title(this.navTitle)
        .menus([
            {
                value: '分享书刊',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
            }
        ])
        .onBackPressed(() => {
            this.pathInfos.pop({
                reloadBookShelf: true,
                inBookshelf: this.isInBookShelf
            } as MainPagePopParam)
            return true
        })
    }
}

@Builder
export function PageBuilder() {
    PageNav()
}

export interface CatalogPageParam {
    itemId?: number
    type?: InfoType
}

@ObservedV2
export class BookInfoObservedV2 implements BookInfoInResponse {
    @Trace catalogs: CatalogInInfo[]
    @Trace bigCover: string
    @Trace author: string
    @Trace publish: string
    @Trace id: number
    @Trace name: string
    @Trace summary: string
    @Trace cover: string
    @Trace isbn: string

    constructor(init: BookInfoInResponse) {
        this.catalogs = init.catalogs
        this.bigCover = init.bigCover
        this.author = init.author
        this.publish = init.publish
        this.id = init.id
        this.name = init.name
        this.summary = init.summary
        this.cover = init.cover
        this.isbn = init.isbn
    }
}

@ObservedV2
export class IssueInfoInObservedV2 implements IssueInfoInResponse {
    @Trace id: number
    @Trace name: string
    @Trace cover: string
    @Trace magazine: MagazineInfoObservedV2
    @Trace catalogs: CatalogInInfo[]

    constructor(init: IssueInfoInResponse) {
        this.id = init.id
        this.name = init.name
        this.cover = init.cover
        this.magazine = new MagazineInfoObservedV2(init.magazine)
        this.catalogs = init.catalogs
    }
}

@ObservedV2
export class MagazineInfoObservedV2 implements MagazineListItem {
    @Trace cn: string
    @Trace issn: string
    @Trace id: number
    @Trace name: string
    @Trace summary: string
    @Trace cover: string

    constructor(init: MagazineListItem) {
        this.cn = init.cn
        this.issn = init.issn
        this.id = init.id
        this.name = init.name
        this.summary = init.summary
        this.cover = init.cover
    }
}


