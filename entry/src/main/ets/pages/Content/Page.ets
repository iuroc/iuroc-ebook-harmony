@ComponentV2
struct Page {
    @Require @Param navTitle: string
    @Event changeNavTitle: (value: string) => void
    @Local contentType: 'book' | 'issue' | null = null
    @Local itemId: number | null = null

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
    itemId: number
}