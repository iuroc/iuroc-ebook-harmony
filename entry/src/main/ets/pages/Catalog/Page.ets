import { BookInfoInResponse, getInfo, InfoType, IssueInfoInResponse, } from './util'
import { promptAction } from '@kit.ArkUI'
import { Catalog } from '../Index/common/lib'
import { MagazineListItem } from '../Index/panels/magazine/MagazinePanel'
import { apiOrigin } from '../../common/config'
import { BSColor } from '@iuroc/bootstrap5-color'
import { extname, extToMime, getPreviewFileUriForImageURL, replaceChinesePunctuation } from '../../common/util'
import { filePreview } from '@kit.PreviewKit'

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
    @Local itemId?: number
    @Local type?: InfoType
    @Local cover: string = ''
    @Local bookInfo?: BookInfoObservedV2
    @Local issueInfo?: IssueInfoInObservedV2

    aboutToAppear(): void {
        const param = this.queryNavDestinationInfo()?.param
        if (param) {
            this.itemId = (param as CatalogPageParam).itemId
            this.type = (param as CatalogPageParam).type

            getInfo(this.itemId as number, this.type as InfoType).then(result => {
                if (this.type == 'book') {
                    this.bookInfo = new BookInfoObservedV2(result as BookInfoInResponse)
                    this.changeNavTitle('图书详情')
                } else if (this.type == 'issue') {
                    this.issueInfo = new IssueInfoInObservedV2(result as IssueInfoInResponse)
                    this.changeNavTitle('期刊详情')
                }
            }).catch((error: Error) => {
                promptAction.showToast(error)
            })
        }
    }

    build() {

        Scroll() {
            Column() {
                Row({ space: 15 }) {
                    Column({ space: 10 }) {
                        Text(this.type == 'book' ? this.bookInfo?.name : this.issueInfo?.magazine.name)
                            .fontWeight(FontWeight.Bold)
                            .width('100%')
                            .maxLines(1)
                            .textAlign(TextAlign.JUSTIFY)
                            .wordBreak(WordBreak.BREAK_ALL)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
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

                        Row({ space: 10 }) {
                            Button('开始阅读').layoutWeight(1)
                            Button('添加收藏').backgroundColor(BSColor.warning).layoutWeight(1)
                        }
                        .width('100%')
                    }
                    .layoutWeight(1)

                    Image(this.getCover(false))
                        .height(150)
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
                .padding(15)
            }
            .width('100%')
        }
        .height('100%')
        .width('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }

    getCover(useBig: boolean) {
        return apiOrigin + (this.type == 'book'
            ? (useBig ? this.bookInfo?.bigCover : this.bookInfo?.cover)
            : this.issueInfo?.cover)
    }
}

@ComponentV2
struct PageNav {
    @Local navTitle: string = ''

    build() {
        NavDestination() {
            Page({
                changeNavTitle: title => {
                    this.navTitle = title
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

export interface CatalogPageParam {
    itemId?: number
    type?: InfoType
}

@ObservedV2
export class BookInfoObservedV2 implements BookInfoInResponse {
    @Trace catalogs: Catalog[]
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
    @Trace catalogs: Catalog[]

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