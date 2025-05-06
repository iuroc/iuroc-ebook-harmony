import { BookListItemInResponse } from "../Index/common/mixin"
import { BookListItemCard } from "../Index/panels/book/BookListItemCard"
import { IssueListItemCard } from "../Issue/IssueListItem"
import { IssueInResponse } from "../Issue/mixin"
import { deleteHistories, getHistories, HistoryInResponse } from "./utils"
import { promptAction } from "@kit.ArkUI"
import { BSColor } from "@iuroc/bootstrap5-color"

@ComponentV2
struct Page {
    @Local items: HistoryInResponse[] = []

    aboutToAppear(): void {
        this.reloadList()
    }

    reloadList() {
        getHistories().then(result => {
            this.items.splice(0)
            this.items.push(...result)
        })
    }

    longPressGesture(item: HistoryInResponse, index: number) {
        AlertDialog.show({
            title: '删除提示',
            message: '确定要删除这篇笔记吗？',
            buttons: [
                {
                    value: '确定删除',
                    action: () => {
                        deleteHistories([item.item.id]).then(() => {
                            this.items.splice(index, 1)
                        }).catch((error: Error) => {
                            AlertDialog.show(error)
                        })
                    },
                    fontColor: BSColor.danger
                },
                {
                    value: '取消',
                    fontColor: BSColor.dark,
                    action: () => {

                    }
                }
            ]
        })
    }

    build() {
        NavDestination() {
            Column({ space: 10 }) {
                Scroll() {
                    Column() {
                        ForEach(this.items, (item: HistoryInResponse, index) => {
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
                                    .gesture(LongPressGesture().onAction(() => {
                                        this.longPressGesture(item, index)
                                    }))
                            } else if (item.item.type == 'issue') {
                                IssueListItemCard({
                                    issue: item.data as IssueInResponse,
                                    magazine: (item.data as IssueInResponse).magazine,
                                    inBookshelf: true,
                                    reloadBookShelf: () => {
                                        this.reloadList()
                                    }
                                })
                                    .gesture(LongPressGesture().onAction(() => {
                                        this.longPressGesture(item, index)
                                    }))
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
        .title('阅读历史')
    }
}

@Builder
export function PageBuilder() {
    Page()
}