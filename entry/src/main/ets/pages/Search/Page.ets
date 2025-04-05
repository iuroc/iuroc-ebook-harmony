import { BookListItemInResponse, getItems, MagazineItemInResponse } from "../Index/common/mixin"
import { BookListItemCard } from "../Index/panels/book/BookListItemCard"
import { MagazineListItemCard } from "../Index/panels/magazine/MagazineListItemCard"
import { promptAction } from "@kit.ArkUI"

@ComponentV2
struct Page {
    @Local items: (BookListItemInResponse | MagazineItemInResponse)[] = []
    @Local keyword: string = ''
    @Local showNoResultTip: boolean = false
    @Local loading: boolean = false

    aboutToAppear(): void {

    }

    build() {
        NavDestination() {
            Column() {
                Row({ space: 10 }) {
                    Search({
                        placeholder: '请输入搜索关键词',
                        value: $$this.keyword
                    })
                        .defaultFocus(true)
                        .layoutWeight(1)
                    Button('搜索')
                        .enabled(this.keyword.trim().length > 0 && !this.loading)
                        .onClick(() => {
                            this.getUIContext().getFocusController().clearFocus()
                            const keyword = this.keyword.trim()
                            this.showNoResultTip = false
                            this.loading = true
                            getItems(-1, 0, 72, keyword).then(result => {
                                if (result.length == 0) {
                                    this.showNoResultTip = true
                                } else {
                                    this.items.splice(0)
                                    this.items.push(...result)
                                }
                            }).catch((error: Error) => {
                                promptAction.showToast(error)
                            }).finally(() => {
                                this.loading = false
                            })
                        })
                }
                .padding({
                    left: 15,
                    right: 15,
                })

                if (this.showNoResultTip) {
                    Text('暂无搜索结果').padding({
                        top: 30,
                        bottom: 30
                    })
                } else {
                    Scroll() {
                        Column() {
                            ForEach(this.items, (item: BookListItemInResponse | MagazineItemInResponse, index) => {
                                if (item.type == 'book') {
                                    BookListItemCard({
                                        author: (item as BookListItemInResponse).author,
                                        name: (item as BookListItemInResponse).name,
                                        publish: (item as BookListItemInResponse).publish,
                                        summary: (item as BookListItemInResponse).summary,
                                        cover: (item as BookListItemInResponse).cover,
                                        bigCover: (item as BookListItemInResponse).bigCover,
                                        itemId: (item as BookListItemInResponse).id,
                                    })
                                } else if (item.type == 'magazine') {
                                    MagazineListItemCard({
                                        name: (item as MagazineItemInResponse).name,
                                        cover: (item as MagazineItemInResponse).cover,
                                        cn: (item as MagazineItemInResponse).cn,
                                        issn: (item as MagazineItemInResponse).issn,
                                        itemId: (item as MagazineItemInResponse).id,
                                        summary: (item as MagazineItemInResponse).summary,
                                    })
                                }
                            })
                        }
                    }
                    .onTouch(event => {
                        if (event.type == TouchType.Down) {
                            this.getUIContext().getFocusController().clearFocus()
                        }
                    })
                    .align(Alignment.Top)
                    .width('100%')
                    .layoutWeight(1)
                    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                }
            }
        }
        .hideTitleBar(true)
    }
}

@Builder
export function PageBuilder() {
    Page()
}