import { getCategories } from '../common/mixin'
import { promptAction } from '@kit.ArkUI'
import { Book, BookCategory } from '../common/lib'

@ComponentV2
export struct BookPanel {
    /** 类型选项列表 */
    @Require @Param categories: CategoryTabItem[]
    /** 图书列表 */
    @Require @Param books: BookListItem[]
    /** 活跃的类型选项下标 */
    @Require @Param activeIndex: number
    /** 是否执行初始化操作，包含联网加载类型列表和图书列表 */
    @Require @Param needInit: boolean
    @Event changeNeedInit: (value: boolean) => void
    @Event changeActiveIndex: (value: number) => void

    aboutToAppear(): void {
        if (this.needInit) {
            getCategories('book').then(result => {
                this.categories.splice(0)
                this.categories.push(...result.map(item => {
                    return { name: item.name, id: item.id } as CategoryTabItem
                }))
                this.changeNeedInit(false)
            }).catch((error: Error) => {
                promptAction.showToast(error)
            })
        }
    }

    build() {
        Column({ space: 15 }) {
            Scroll() {
                Row({ space: 5 }) {
                    ForEach(this.categories, (category: CategoryTabItem, index) => {
                        Button(category.name)
                            .buttonStyle(this.activeIndex == index
                                ? ButtonStyleMode.EMPHASIZED
                                : ButtonStyleMode.NORMAL)
                            .onClick(() => {
                                this.changeActiveIndex(index)
                            })
                    })
                }
                .padding({ left: 10, right: 10 })
            }
            .width('100%')
            .scrollable(ScrollDirection.Horizontal)
            .scrollBarWidth(0)
        }
        .width('100%')
        .padding({ top: 5, bottom: 5 })
    }
}

export interface CategoryTabItem {
    name: string
    id: number
}

export interface BookListItem {
    author: string
    /** 出版社名称 */
    publish: string
    /** 大尺寸封面 */
    bigCover: string
    id: number
    name: string
    /** 内容介绍 */
    summary: string
    /** 普通封面 */
    cover: string
}