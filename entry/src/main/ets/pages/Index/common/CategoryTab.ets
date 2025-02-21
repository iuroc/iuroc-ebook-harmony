@ComponentV2
export struct CategoryTab {
    @Require @Param categories: CategoryTabItem[]
    @Require @Param activeCategoryIndex: number
    @Event handleClick: (index: number) => void

    build() {
        Scroll() {
            Row({ space: 5 }) {
                ForEach(this.categories, (category: CategoryTabItem, index) => {
                    Button(category.name)
                        .buttonStyle(this.activeCategoryIndex == index
                            ? ButtonStyleMode.EMPHASIZED
                            : ButtonStyleMode.NORMAL)
                        .onClick(() => {
                            this.handleClick(index)
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