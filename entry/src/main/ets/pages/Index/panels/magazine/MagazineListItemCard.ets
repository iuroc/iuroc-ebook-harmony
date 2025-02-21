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
    }
}