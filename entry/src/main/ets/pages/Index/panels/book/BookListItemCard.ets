import { CatalogPageParam } from '../../../Catalog/Page'
import { ItemCard } from '../../components/ItemCard'

@ComponentV2
export struct BookListItemCard {
    @Require @Param itemId: number
    @Require @Param name: string
    @Require @Param author: string
    @Require @Param summary: string
    @Require @Param publish: string
    @Require @Param cover: string
    @Require @Param bigCover: string
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

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
            .onClick(() => {
                this.pathInfos.pushPath({
                    name: 'Catalog', param: {
                        itemId: this.itemId,
                        type: 'book'
                    } as CatalogPageParam
                })
            })
    }
}