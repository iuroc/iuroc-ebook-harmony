import { promptAction } from "@kit.ArkUI"

@ComponentV2
struct Page {
    @Require @Param navTitle: string
    @Event changeNavTitle: (value: string) => void
    @Local contentType: 'book' | 'issue' | null = null
    @Local itemId: number | null = null
    @Local currentBookPage: number | null = null
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    aboutToAppear(): void {
        const param = this.queryNavDestinationInfo()?.param as ContentPageParam | undefined
        if (!param) {
            promptAction.showToast({ message: '页面参数错误' })
            this.pathInfos.pop()
            return
        }

        this.itemId = param.itemId
        this.contentType = param.type
        this.currentBookPage = param.currentBookPage
    }

    build() {

    }
}

@ComponentV2
struct PageNav {
    @Local navTitle: string = ''

    build() {
        NavDestination() {
            Page({
                navTitle: this.navTitle,
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

export interface ContentPageParam {
    type: 'book' | 'issue'
    /** bookId 或 issueId */
    itemId: number
    /** 书刊页码，从 1 开始 */
    currentBookPage: number
}