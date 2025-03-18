import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { NotePagePopParam } from "../Page"
import { createNote, getOneNote, updateNote } from "../utils"

@ComponentV2
struct Page {
    @Local title: string = ''
    @Local content: string = ''
    @Local mode: 'add' | 'edit' | null = null
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    editNodeId: number = 0

    aboutToAppear(): void {
        const params = this.pathInfos.getParamByName('NoteEdit') as Object[]
        if (params[0]) {
            const param = params[0] as NoteEditPageParam
            this.editNodeId = param.editNoteId
            getOneNote(param.editNoteId).then(note => {
                this.title = note.title
                this.content = note.content
                this.mode = 'edit'
            })
        } else {
            this.mode = 'add'
        }
    }

    build() {
        NavDestination() {
            Scroll() {
                Column({ space: 15 }) {
                    TextInput({ text: $$this.title, placeholder: '笔记标题' })
                    TextArea({
                        text: $$this.content,
                        placeholder: '笔记内容'
                    }).constraintSize({ minHeight: 250 })
                }
                .padding({ left: 15, right: 15, bottom: 15 })
            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
        }
        .title(this.mode == 'add' ? '新增笔记' : '编辑笔记')
        .menus([
            {
                value: '保存',
                isEnabled: !!this.mode && !!this.content,
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.checkmark')),
                action: () => {
                    if (this.mode == 'add') {
                        createNote(this.title, this.content).then(result => {
                            promptAction.showToast({ message: '创建成功' })
                            this.pathInfos.pop({
                                from: 'NoteEdit',
                                needReload: true
                            } as NotePagePopParam)
                        }).catch((error: Error) => {
                            promptAction.showToast(error)
                        })
                    } else if (this.mode == 'edit') {
                        updateNote(this.editNodeId, this.title, this.content).then(result => {
                            promptAction.showToast({ message: '更新成功' })
                            this.pathInfos.pop({
                                from: 'NoteEdit',
                                needReload: true
                            } as NotePagePopParam)
                        }).catch((error: Error) => {
                            promptAction.showToast(error)
                        })
                    }
                }
            }
        ])
    }
}

@Builder
export function PageBuilder() {
    Page()
}

export interface NoteEditPageParam {
    editNoteId: number
}