import { deleteNote, getNotes, NoteInResponse } from "./utils"
import { ComposeListItem } from "@ohos.arkui.advanced.ComposeListItem"
import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { BSColor } from "@iuroc/bootstrap5-color"
import { NoteViewPageParam } from "./View/Page"

@ComponentV2
struct Page {
    @Local notes: NoteInResponse[] = []
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    aboutToAppear(): void {
        this.reloadList()
    }

    reloadList() {
        getNotes(0, 72).then(notes => {
            this.notes = notes
        })
    }

    build() {
        NavDestination() {
            List() {
                ForEach(this.notes, (note: NoteInResponse, index) => {
                    ListItem() {
                        ComposeListItem({
                            contentItem: {
                                primaryText: note.title,
                                secondaryText: note.content,
                                description: note.createAt
                            }
                        })
                            .onClick(() => {
                                this.pathInfos.pushPath({
                                    name: 'NoteView', param: {
                                        noteId: note.id
                                    } as NoteViewPageParam,
                                    onPop: info => {
                                        if ((info.result as NotePagePopParam).needReload) {
                                            this.reloadList()
                                        }
                                    }
                                })
                            })
                            .gesture(LongPressGesture().onAction(() => {
                                AlertDialog.show({
                                    title: '删除提示',
                                    message: '确定要删除这篇笔记吗？',
                                    buttons: [
                                        {
                                            value: '确定删除',
                                            action: () => {
                                                deleteNote(note.id).then(() => {
                                                    promptAction.showToast({ message: '删除成功' })
                                                    this.notes.splice(index, 1)
                                                }).catch((error: Error) => {
                                                    promptAction.showToast(error)
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
                            }))
                    }
                })
            }
            .padding({ left: 10, right: 10, bottom: 10 })
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .title('阅读笔记')
        .menus([
            {
                value: '新增笔记',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
                action: () => {
                    this.pathInfos.pushPath({
                        name: 'NoteEdit', onPop: info => {
                            if ((info.result as NotePagePopParam).needReload) {
                                this.reloadList()
                            }
                        }
                    })
                }
            }
        ])
    }
}

@Builder
export function PageBuilder() {
    Page()
}

export interface NotePagePopParam {
    from: string
    needReload: boolean
}