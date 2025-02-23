import { MagazineListItem } from '../Index/panels/magazine/MagazinePanel'
import { promptAction } from '@kit.ArkUI'
import { IssueListItemCard } from './IssueListItem'
import { getIssues, IssueInResponse } from './mixin'
import { MagazineListItemCard } from '../Index/panels/magazine/MagazineListItemCard'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local issues: IssueListItem[] = []
    private param?: IssuePageParam
    @Event changeNavTitle: (value: string) => void

    aboutToAppear(): void {
        this.param = this.queryNavDestinationInfo()?.param as IssuePageParam
        if (!this.param) {
            promptAction.showToast({ message: '页面参数不能为空' })
            this.pathInfos.pop()
        }

        this.changeNavTitle(this.param.name)

        getIssues(this.param.id, 0, 36).then(result => {
            this.issues.push(...result.map(item => {
                return item as IssueListItem
            }))
        }).catch((error: Error) => {
            promptAction.showToast(error)
        })
    }

    build() {
        Scroll() {
            Column() {
                ForEach(this.issues, (issue: IssueListItem, index) => {
                    IssueListItemCard({
                        magazine: this.param,
                        issue,
                    })
                })
            }
            .width('100%')
        }
        .width('100%')
        .height('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}

@ComponentV2
struct PageNav {
    @Local navTitle: string = ''

    build() {
        NavDestination() {
            Page({
                changeNavTitle: value => {
                    this.navTitle = value
                }
            })
        }
        .title(this.navTitle)
    }
}

@Builder
export function PageBuilder() {
    PageNav()
}

/** 进入 Issue 页面时要求传入的参数结构 */
export interface IssuePageParam extends MagazineListItem {}

export interface IssueListItem extends IssueInResponse {}