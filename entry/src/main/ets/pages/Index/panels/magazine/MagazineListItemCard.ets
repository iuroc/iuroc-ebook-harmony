import { IssuePageParam } from '../../../Issue/Page'
import { ItemCard } from '../../components/ItemCard'

@ComponentV2
export struct MagazineListItemCard {
    @Require @Param itemId: number
    @Require @Param name: string
    @Require @Param summary: string
    @Require @Param cover: string
    /** 国内刊号 */
    @Require @Param cn: string = ''
    /** 国际刊号 */
    @Require @Param issn: string = ''
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        ItemCard({
            itemId: this.itemId,
            name: this.name,
            summary: this.summary,
            cover: this.cover,
            type: 'magazine',
            cn: this.cn,
            issn: this.issn
        })
            .onClick(() => {
                this.pathInfos.pushPath({
                    name: 'Issue', param: {
                        id: this.itemId,
                        name: this.name,
                        summary: this.summary,
                        cover: this.cover,
                        cn: this.cn,
                        issn: this.issn
                    } as IssuePageParam
                })
            })
    }
}