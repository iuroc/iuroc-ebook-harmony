import { SymbolGlyphModifier } from '@kit.ArkUI'
import {
    checkToken,
    getUseInfoFromPreferences,
    saveUserInfoToPreferences,
    TokenError,
    UserInResponse
} from '../common/token'
import { BookListItem, BookPanel } from './Book/Panel'
import { RecommendPanel } from './Recommend/Panel'
import { common } from '@kit.AbilityKit'
import { UserPanel } from './User/Panel'
import { MagazineListItem, MagazinePanel } from './Magazine/Panel'
import { CategoryTabItem } from './common/CategoryTab'

@Entry
@ComponentV2
struct Page {
    @Local activePageIndex: number = 1
    // Navigation
    @Provider() pathInfos: NavPathStack = new NavPathStack()
    private titles = ['精彩推荐', '图书列表', '期刊列表', '实用工具', '个人中心']
    private titleModes: NavigationTitleMode[] = [
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
    ]
    @Local showNavigation: boolean = false
    @Local showContent: boolean = false
    // RecommendPanel
    @Local recommendPanelNeedInit: boolean = true
    // BookPanel
    @Local bookPanelNeedInit: boolean = true
    @Local bookPanelActiveCategoryIndex: number = 0
    @Local bookPanelCategories: CategoryTabItem[] = []
    @Local bookPanelBooks: BookListItem[] = []
    // MagazinePanel
    @Local magazinePanelNeedInit: boolean = true
    @Local magazinePanelActiveCategoryIndex: number = 0
    @Local magazinePanelCategories: CategoryTabItem[] = []
    @Local magazinePanelItems: MagazineListItem[] = []

    aboutToAppear(): void {
        checkToken().then(async user => {
            await saveUserInfoToPreferences(user as UserInResponse)
            console.log(JSON.stringify(await getUseInfoFromPreferences()))
            this.showContent = true
        }).catch((error: Error) => {
            if (error instanceof TokenError) {
                this.pathInfos.pushPath({
                    name: 'Login', onPop: () => {
                        this.showContent = true
                    }
                }, false)
            } else {
                (getContext() as common.UIAbilityContext).terminateSelf()
            }
        }).finally(() => this.showNavigation = true)
    }

    @Builder
    NavigationContent() {
        if (this.activePageIndex == 0) {
            RecommendPanel()
        } else if (this.activePageIndex == 1) {
            BookPanel({
                needInit: this.bookPanelNeedInit,
                activeCategoryIndex: this.bookPanelActiveCategoryIndex,
                categories: this.bookPanelCategories,
                changeNeedInit: value => this.bookPanelNeedInit = value,
                changeActiveCategoryIndex: value => this.bookPanelActiveCategoryIndex = value,
                items: this.bookPanelBooks,
            })
        } else if (this.activePageIndex == 2) {
            MagazinePanel({
                needInit: this.magazinePanelNeedInit,
                activeCategoryIndex: this.magazinePanelActiveCategoryIndex,
                categories: this.magazinePanelCategories,
                changeNeedInit: value => this.magazinePanelNeedInit = value,
                changeActiveCategoryIndex: value => this.magazinePanelActiveCategoryIndex = value,
                items: this.magazinePanelItems
            })
        } else if (this.activePageIndex == 4) {
            UserPanel()
        }
    }

    build() {
        if (this.showNavigation)
        Navigation(this.pathInfos) {
            if (this.showContent) {
                this.NavigationContent()
            }
        }
        .hideBackButton(true)
        .titleMode(this.titleModes[this.activePageIndex])
        .title(this.titles[this.activePageIndex])
        .menus([
            {
                value: '搜索',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')),
            },
            {
                value: '助手',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.vertical_flip'))
            }
        ])
        .toolbarConfiguration(
            this.toolbarItems().map((item, index) => {
                item.action = () => this.activePageIndex = index
                item.status = this.activePageIndex == index ? ToolbarItemStatus.ACTIVE : ToolbarItemStatus.NORMAL
                return item
            })
        )
    }

    toolbarItems(): ToolbarItem[] {
        return [
            {
                value: '推荐',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.label')),
                activeSymbolIcon: new SymbolGlyphModifier($r('sys.symbol.label')),
            },
            {
                value: '图书',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.book')),
                activeSymbolIcon: new SymbolGlyphModifier($r('sys.symbol.book')),
            },
            {
                value: '期刊',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_square_bill')),
                activeSymbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_square_bill')),
            },
            {
                value: '工具',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.more')),
                activeSymbolIcon: new SymbolGlyphModifier($r('sys.symbol.more')),
            },
            {
                value: '我的',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.person')),
                activeSymbolIcon: new SymbolGlyphModifier($r('sys.symbol.person')),
            }
        ]
    }
}