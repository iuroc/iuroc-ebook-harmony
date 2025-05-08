import { BSColor } from "@iuroc/bootstrap5-color"
import { apiOrigin } from "../../common/config"
import { CatalogPageParam } from "../Catalog/Page"
import { makeImageSrc } from "../Index/common/mixin"
import { MainPagePopParam } from "../Index/Page"
import { MagazineListItem } from "../Index/panels/magazine/MagazinePanel"
import { IssueListItem } from "./Page"

@ComponentV2
export struct IssueListItemCard {
    @Require @Param issue: IssueListItem
    @Require @Param magazine: MagazineListItem
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Param inBookshelf: boolean = false
    @Param reloadBookShelf: () => void = () => {
    }

    build() {
        Row({ space: 10 }) {
            if (this.inBookshelf) {
                Image(makeImageSrc(this.issue.cover)).width(100 * 0.8).height(140 * 0.8)
                    .borderRadius(5)
                    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
            } else {
                Image(makeImageSrc(this.issue.cover)).width(50).height(70)
                    .borderRadius(5)
                    .shadow(ShadowStyle.OUTER_DEFAULT_XS)
            }

            Column({ space: 5 }) {

                if (this.inBookshelf) {
                    Text(this.magazine.name)
                        .fontWeight(FontWeight.Bold)
                        .width('100%')
                        .maxLines(1)
                        .wordBreak(WordBreak.BREAK_ALL)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(this.issue.name)
                        .wordBreak(WordBreak.BREAK_ALL)
                        .maxLines(1)
                        .fontColor(BSColor.info_text_emphasis)
                        .fontSize(12)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                } else {
                    Text(this.issue.name)
                        .fontWeight(FontWeight.Bold)
                        .width('100%')
                        .maxLines(1)
                        .wordBreak(WordBreak.BREAK_ALL)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row({ space: 5 }) {
                        Text(`CN ${this.magazine.cn || '暂无编号'}`)
                            .wordBreak(WordBreak.BREAK_ALL)
                            .maxLines(1)
                            .fontColor(BSColor.info_text_emphasis)
                            .fontSize(12)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .constraintSize({
                                maxWidth: '50%'
                            })
                        Divider().vertical(true).height(15)
                        Text(`ISSN ${this.magazine.issn || '暂无编号'}`)
                            .wordBreak(WordBreak.BREAK_ALL)
                            .maxLines(1)
                            .fontColor(BSColor.secondary_text_emphasis)
                            .fontSize(12)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .layoutWeight(1)
                    }
                    .clip(true)
                    .width('100%')

                    Text(this.magazine.name)
                        .fontSize(12)
                        .wordBreak(WordBreak.BREAK_ALL)
                        .maxLines(1)
                        .fontColor(BSColor.secondary)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                }

                if (this.inBookshelf) {
                    Text(this.magazine.summary || '暂无书刊介绍')
                        .fontSize(12)
                        .fontColor(BSColor.secondary)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .wordBreak(WordBreak.BREAK_ALL)
                        .textAlign(TextAlign.JUSTIFY)
                        .width('100%')
                        .maxLines(5)
                }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
        }
        .stateStyles({
            pressed: {
                .backgroundColor(BSColor.info_bg_subtle)
            },
            normal: {
                .backgroundColor(Color.Transparent)
            }
        })
        .padding({
            left: 15,
            right: 15,
            top: 7.5,
            bottom: 7.5
        })
        .onClick(() => {
            this.pathInfos.pushPath({
                name: 'Catalog', param: {
                    itemId: this.issue.id,
                    type: 'issue',
                } as CatalogPageParam,
                onPop: info => {
                    if (info.result) {
                        const result = info.result as MainPagePopParam
                        if (result.reloadBookShelf && !result.inBookshelf) {
                            this.reloadBookShelf()
                        }
                    }
                }
            })
        })
    }
}