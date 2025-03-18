import { deleteNote, getOneNote } from "../utils"
import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { BSColor } from "@iuroc/bootstrap5-color"
import { NoteEditPageParam } from "../Edit/Page"
import { systemShareTextWithToast } from "@iuroc/chat-page"
import { NotePagePopParam } from "../Page"

@ComponentV2
struct Page {
    @Local title: string = ''
    @Local content: string = ''
    @Local noteId: number = 0
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    hasBeEdit = false

    aboutToAppear(): void {
        if (this.pathInfos.getParamByName('NoteView').length > 0) {
            const param = this.pathInfos.getParamByName('NoteView')[0] as NoteViewPageParam
            this.noteId = param.noteId
            this.reload()
        } else {
            promptAction.showToast({ message: '页面参数缺失' })
            this.pathInfos.pop()
        }
    }

    reload() {
        getOneNote(this.noteId).then(note => {
            this.title = note.title
            this.content = note.content
        }).catch((error: Error) => {
            promptAction.showToast(error)
        })
    }

    build() {
        NavDestination() {
            Scroll() {
                Column({ space: 15 }) {
                    Text(this.title)
                        .fontWeight(FontWeight.Bold)
                        .textAlign(TextAlign.JUSTIFY)
                        .wordBreak(WordBreak.BREAK_ALL)
                        .letterSpacing(1)
                        .width('100%')
                        .fontSize(18)
                        .copyOption(CopyOptions.LocalDevice)
                    Divider()
                    Text(this.content)
                        .textAlign(TextAlign.JUSTIFY)
                        .wordBreak(WordBreak.BREAK_ALL)
                        .letterSpacing(1)
                        .width('100%')
                        .copyOption(CopyOptions.LocalDevice)
                }
                .padding(15)
                .width('100%')
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
        }
        .onBackPressed(() => {
            this.pathInfos.pop({
                from: 'NoteView',
                needReload: this.hasBeEdit
            } as NotePagePopParam)
            return true
        })
        .title('查看笔记')
        .menus([
            {
                value: '分享笔记',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.share')),
                action: () => {
                    systemShareTextWithToast(this.title, `【${this.title}】\n\n${this.content}`)
                }
            },
            {
                value: '编辑笔记',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil')),
                action: () => {
                    this.pathInfos.pushPath({
                        name: 'NoteEdit', param: {
                            editNoteId: this.noteId
                        } as NoteEditPageParam,
                        onPop: info => {
                            this.hasBeEdit = true
                            this.reload()
                        }
                    })
                }
            },
            {
                value: '删除笔记',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.trash')).fontColor([BSColor.danger]),
                action: () => {
                    AlertDialog.show({
                        title: '删除笔记',
                        message: '确定要删除这篇笔记吗？',
                        buttons: [
                            {
                                value: '确定删除',
                                fontColor: BSColor.danger,
                                action: () => {
                                    deleteNote(this.noteId).then(() => {
                                        promptAction.showToast({ message: '删除成功' })
                                        this.pathInfos.pop({
                                            from: 'NoteView',
                                            needReload: true
                                        } as NotePagePopParam)
                                    })
                                }
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
            }
        ])
    }
}

@Builder
export function PageBuilder() {
    Page()
}

export interface NoteViewPageParam {
    noteId: number
}