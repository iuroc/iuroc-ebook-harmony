import { display } from "@kit.ArkUI"

@ComponentV2
export struct CategoryTab {
    @Require @Param categories: CategoryTabItem[]
    @Require @Param activeCategoryIndex: number
    /** 切换分类选项卡 */
    @Event changeActiveIndex: (index: number) => void
    /** 清空列表并重新加载指定分类的书刊列表 */
    @Event clearAndLoadList: (categoryId: number) => Promise<void>
    scroller = new Scroller()
    buttonWidth = 0
    defaultDisplayWidth = px2vp(display.getDefaultDisplaySync().width)

    build() {
        Scroll(this.scroller) {
            Row({ space: 5 }) {
                ForEach(this.categories, (category: CategoryTabItem, index) => {
                    Button(category.name)
                        .onAreaChange((_oldValue, newValue) => {
                            this.buttonWidth = newValue.width as number
                        })
                        .buttonStyle(this.activeCategoryIndex == index
                            ? ButtonStyleMode.EMPHASIZED
                            : ButtonStyleMode.NORMAL)
                        .onClick(async () => {
                            this.scrollToIndex(index)
                            if (this.activeCategoryIndex != index) {
                                this.changeActiveIndex(index)
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
        .onAppear(() => {
            this.scrollToIndex(this.activeCategoryIndex, false)
        })
    }

    scrollToIndex(index: number, animation = true) {
        this.scroller.scrollTo({
            yOffset: 0,
            xOffset: this.scroller.getItemRect(0).width * (index / this.categories.length)
                - this.defaultDisplayWidth / 2  // 屏幕宽度的一半
                + this.buttonWidth / 2, // 单个按钮宽度的一半
            animation
        })
    }
}

export interface CategoryTabItem {
    name: string
    id: number
}