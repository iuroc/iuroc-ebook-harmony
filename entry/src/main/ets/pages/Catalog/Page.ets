import { BookInfoInResponse, getInfo, InfoType, MagazineInfoInResponse as IssueInfoInResponse } from './util'
import { promptAction } from '@kit.ArkUI'

@ComponentV2
struct Page {
    @Event changeNavTitle: (title: string) => void
    @Local itemId?: number
    @Local type?: InfoType
    @Local bookInfo?: BookInfoInResponse
    @Local issueInfo?: IssueInfoInResponse

    aboutToAppear(): void {
        const param = this.queryNavDestinationInfo()?.param
        if (param) {
            this.itemId = (param as CatalogPageParam).itemId
            this.type = (param as CatalogPageParam).type

            getInfo(this.itemId as number, this.type as InfoType).then(result => {
                if (this.type == 'book') {
                    this.bookInfo = result as BookInfoInResponse
                } else if (this.type ==
                    'issue') {
                    this.issueInfo = result as IssueInfoInResponse
                }
            }).catch((error: Error) => {
                promptAction.showToast(error)
            })
        }
    }

    build() {

        Row({ space: 10 }) {
            Column({ space: 10 }) {
                Text(this.type == 'book' ? this.bookInfo?.name : this.issueInfo?.name)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(18)
            }
        }
        .alignItems(VerticalAlign.Top)
    }
}

@ComponentV2
struct PageNav {
    @Local navTitle: string = ''

    build() {
        NavDestination() {
            Page({
                changeNavTitle: title => {
                    this.navTitle = title
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

export interface CatalogPageParam {
    itemId?: number
    type?: InfoType
}