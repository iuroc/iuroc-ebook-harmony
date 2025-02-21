import { BookListItemInResponse, CommonListItem, getCategories, getItems } from '../common/mixin'
import { promptAction } from '@kit.ArkUI'
import { BookListItemCard } from './BookListItemCard'
import { CategoryTab, CategoryTabItem } from '../common/CategoryTab'

@ComponentV2
export struct BookPanel {
    /** 类型选项列表 */
    @Require @Param categories: CategoryTabItem[]
    /** 图书列表 */
    @Require @Param books: BookListItem[]
    /** 活跃的类型选项下标 */
    @Require @Param activeCategoryIndex: number
    /** 是否执行初始化操作，包含联网加载类型列表和图书列表 */
    @Require @Param needInit: boolean
    @Event changeNeedInit: (value: boolean) => void
    @Event changeActiveCategoryIndex: (value: number) => void

    aboutToAppear(): void {
        if (this.needInit) {
            getCategories('book').then(async result => {
                this.categories.splice(0)
                this.categories.push(...result.map(item => {
                    return { name: item.name, id: item.id } as CategoryTabItem
                }))
                await this.clearAndLoadList(this.categories[this.activeCategoryIndex].id)
                this.changeNeedInit(false)
            }).catch((error: Error) => {
                promptAction.showToast(error)
            })
        }
    }

    async clearAndLoadList(categoryId: number) {
        const books = await getItems<BookListItemInResponse>(categoryId, 0, 36)
        this.books.splice(0)
        this.books.push(...books)
    }

    build() {
        Column() {
            CategoryTab({
                categories: this.categories,
                activeCategoryIndex: this.activeCategoryIndex,
                handleClick: index => {
                    if (this.activeCategoryIndex != index) {
                        this.changeActiveCategoryIndex(index)
                        this.clearAndLoadList(this.categories[index].id)
                    }
                }
            })
            Scroll() {
                Column() {
                    ForEach(this.books, (book: BookListItem, index) => {
                        BookListItemCard({
                            name: book.name,
                            author: book.author,
                            summary: book.summary,
                            publish: book.publish,
                            cover: book.cover,
                            bookId: book.id,
                            bigCover: book.bigCover
                        })
                    })
                }
                .padding({
                    top: 15 - 7.5 - 5,
                    bottom: 7.5
                })
            }
            .align(Alignment.Top)
            .layoutWeight(1)
            .width('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .width('100%')
    }
}

export interface BookListItem extends CommonListItem {
    /** 大尺寸封面 */
    bigCover: string
    author: string
    /** 出版社名称 */
    publish: string
}
