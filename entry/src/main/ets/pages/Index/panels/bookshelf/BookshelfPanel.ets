import { BookShelfItemInResponse } from "../../../Catalog/util"
import { IssueListItemCard } from "../../../Issue/IssueListItem"
import { IssueInResponse } from "../../../Issue/mixin"
import { BookListItemInResponse } from "../../common/mixin"
import { BookListItemCard } from "../book/BookListItemCard"
import { BookListItem } from "../book/BookPanel"
import { MagazineListItem } from "../magazine/MagazinePanel"
import { BookshelfInResponse, getBookshelfList } from "./utils"

@ComponentV2
export struct BookshelfPanel {
    @Local items: BookshelfInResponse[] = []

    reloadList() {
        getBookshelfList().then(result => {
            this.items.splice(0)
            this.items.push(...result)
        })
    }

    aboutToAppear(): void {
        this.reloadList()
    }

    build() {
        Column({ space: 10 }) {
            Scroll() {
                Column() {
                    ForEach(this.items, (item: BookshelfInResponse, index) => {
                        if (item.item.type == 'book') {
                            BookListItemCard({
                                author: (item.data as BookListItemInResponse).author,
                                bigCover: (item.data as BookListItemInResponse).bigCover,
                                cover: (item.data as BookListItemInResponse).cover,
                                name: (item.data as BookListItemInResponse).name,
                                itemId: item.item.itemId,
                                publish: (item.data as BookListItemInResponse).publish,
                                summary: (item.data as BookListItemInResponse).summary,
                                inBookshelf: true,
                                reloadBookShelf: () => {
                                    this.reloadList()
                                }
                            })
                        } else if (item.item.type == 'issue') {
                            IssueListItemCard({
                                issue: item.data as IssueInResponse,
                                magazine: (item.data as IssueInResponse).magazine,
                                inBookshelf: true,
                                reloadBookShelf: () => {
                                    this.reloadList()
                                }
                            })
                        }
                    })
                }
                .padding({
                    top: 7.5,
                    bottom: 7.5
                })
            }
            .align(Alignment.Top)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .width('100%')
            .layoutWeight(1)
        }
    }
}