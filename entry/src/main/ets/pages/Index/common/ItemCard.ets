import { BSColor } from '@iuroc/bootstrap5-color'
import { apiOrigin } from '../../common/config'
import { replaceChinesePunctuation } from '../../common/util'
import { EbookType } from './mixin'

@ComponentV2
export struct ItemCard {
    @Require @Param type: EbookType
    @Require @Param itemId: number
    @Require @Param name: string
    @Require @Param summary: string
    @Require @Param cover: string
    // Book
    @Param publish: string = ''
    @Param bigCover: string = ''
    @Param author: string = ''
    // Magazine
    /** 国内刊号 */
    @Param cn: string = ''
    /** 国际刊号 */
    @Param issn: string = ''

    build() {
        Row({ space: 10 }) {
            Image(apiOrigin + this.cover).width(100).height(140)
                .borderRadius(5)
                .shadow(ShadowStyle.OUTER_DEFAULT_XS)
            Column({ space: 5 }) {
                Text(this.name)
                    .fontWeight(FontWeight.Bold)
                    .width('100%')
                    .maxLines(1)
                    .wordBreak(WordBreak.BREAK_ALL)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Row({ space: 5 }) {
                    Text(replaceChinesePunctuation(this.type == 'book' ? this.author : `CN ${this.cn}`))
                        .wordBreak(WordBreak.BREAK_ALL)
                        .maxLines(1)
                        .fontColor(BSColor.info_text_emphasis)
                        .fontSize(12)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .constraintSize({
                            maxWidth: '50%'
                        })
                    Divider().vertical(true).height(15)
                    Text(replaceChinesePunctuation(this.type == 'book' ? this.publish : `ISSN ${this.issn}`))
                        .wordBreak(WordBreak.BREAK_ALL)
                        .maxLines(1)
                        .fontColor(BSColor.secondary_text_emphasis)
                        .fontSize(12)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                }
                .clip(true)
                .width('100%')

                Text(this.summary)
                    .fontSize(12)
                    .fontColor(BSColor.secondary)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .wordBreak(WordBreak.BREAK_ALL)
                    .textAlign(TextAlign.JUSTIFY)
                    .width('100%')
                    .maxLines(7)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Top)
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
    }
}