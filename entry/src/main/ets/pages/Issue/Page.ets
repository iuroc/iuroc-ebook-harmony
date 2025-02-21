import { MagazineListItem } from '../Index/panels/magazine/MagazinePanel'
import { promptAction } from '@kit.ArkUI'
import { IssueListItemCard } from './IssueListItem'
import { getIssues, IssueInResponse } from './mixin'

@ComponentV2
struct Page {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()
    @Local issues: IssueListItem[] = []
    private param?: IssuePageParam

    aboutToAppear(): void {
        this.param = this.queryNavDestinationInfo()?.param as IssuePageParam
        if (!this.param) {
            promptAction.showToast({ message: '页面参数不能为空' })
            this.pathInfos.pop()
        }

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

@Builder
export function PageBuilder() {
    NavDestination() {
        Page()
    }
    .title('期刊分期列表')
}

/** 进入 Issue 页面时要求传入的参数结构 */
export interface IssuePageParam extends MagazineListItem {}

export interface IssueListItem extends IssueInResponse {}