import { ItemCard } from '../../common/ItemCard'

@ComponentV2
export struct BookListItemCard {
    @Require @Param itemId: number
    @Require @Param name: string
    @Require @Param author: string
    @Require @Param summary: string
    @Require @Param publish: string
    @Require @Param cover: string
    @Require @Param bigCover: string

    build() {
        ItemCard({
            itemId: this.itemId,
            name: this.name,
            author: this.author,
            summary: this.summary,
            publish: this.publish,
            cover: this.cover,
            bigCover: this.bigCover,
            type: 'book',
        })
    }
}