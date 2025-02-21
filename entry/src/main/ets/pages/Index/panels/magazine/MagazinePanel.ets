import { CategoryTab, CategoryTabItem } from '../../components/CategoryTab'
import { CommonListItem, getCategories, getItems, MagazineItemInResponse } from '../../common/mixin'
import { MagazineListItemCard } from './MagazineListItemCard'
import { promptAction } from '@kit.ArkUI'

export interface MagazineListItem extends CommonListItem {
    /** 国内刊号 */
    cn: string
    /** 国际刊号 */
    issn: string
}

@ComponentV2
export struct MagazinePanel {
    /** 类型选项列表 */
    @Require @Param categories: CategoryTabItem[]
    /** 期刊列表 */
    @Require @Param items: MagazineListItem[]
    /** 活跃的类型选项下标 */
    @Require @Param activeCategoryIndex: number
    /** 是否执行初始化操作，包含联网加载类型列表和期刊列表 */
    @Require @Param needInit: boolean
    @Event changeNeedInit: (value: boolean) => void
    @Event changeActiveCategoryIndex: (value: number) => void
    scroller = new Scroller()

    aboutToAppear(): void {
        if (this.needInit) {
            getCategories('magazine').then(async result => {
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

    build() {
        Column() {
            CategoryTab({
                categories: this.categories,
                activeCategoryIndex: this.activeCategoryIndex,
                changeActiveIndex: index => this.changeActiveCategoryIndex(index),
                clearAndLoadList: async categoryId => await this.clearAndLoadList(categoryId)
            })
            Scroll(this.scroller) {
                Column() {
                    ForEach(this.items, (magazine: MagazineListItem, index) => {
                        MagazineListItemCard({
                            itemId: magazine.id,
                            name: magazine.name,
                            summary: magazine.summary,
                            cover: magazine.cover,
                            cn: magazine.cn,
                            issn: magazine.issn
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

    async clearAndLoadList(categoryId: number) {
        const magazines = await getItems<MagazineItemInResponse>(categoryId, 0, 36)
        this.items.splice(0)
        this.items.push(...magazines)
        this.scroller.scrollTo({ yOffset: 0, xOffset: 0 })
    }
}