@ComponentV2
export struct CategoryTab {
    @Require @Param categories: CategoryTabItem[]
    @Require @Param activeCategoryIndex: number
    /** 切换分类选项卡 */
    @Event changeActiveIndex: (index: number) => void
    /** 清空列表并重新加载指定分类的书刊列表 */
    @Event clearAndLoadList: (categoryId: number) => Promise<void>

    build() {
        Scroll() {
            Row({ space: 5 }) {
                ForEach(this.categories, (category: CategoryTabItem, index) => {
                    Button(category.name)
                        .buttonStyle(this.activeCategoryIndex == index
                            ? ButtonStyleMode.EMPHASIZED
                            : ButtonStyleMode.NORMAL)
                        .onClick(async () => {
                            this.changeActiveIndex(index)
                            if (this.activeCategoryIndex != index) {
                                await this.clearAndLoadList(this.categories[index].id)
                            }
                        })
                })
            }
            .padding({
                left: 10,
                right: 10,
                bottom: 5,
                top: 5
            })
        }
        .width('100%')
        .scrollable(ScrollDirection.Horizontal)
        .scrollBarWidth(0)
        .edgeEffect(EdgeEffect.Spring)
    }
}

export interface CategoryTabItem {
    name: string
    id: number
}