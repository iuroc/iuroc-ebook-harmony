import { SymbolGlyphModifier } from '@kit.ArkUI'
import {
    checkToken,
    getUseInfoFromPreferences,
    saveUserInfoToPreferences,
    TokenError,
    UserInResponse
} from '../../common/token'
import { BookListItem, BookPanel } from './panels/book/BookPanel'
import { RecommendPanel } from './panels/recommend/RecommendPanel'
import { common } from '@kit.AbilityKit'
import { UserPanel } from './panels/user/UserPanel'
import { MagazineListItem, MagazinePanel } from './panels/magazine/MagazinePanel'
import { CategoryTabItem } from './components/CategoryTab'
import { ToolPanel } from './panels/tool/ToolPanel'

@Entry
@ComponentV2
struct Page {
    @Local activePageIndex: number = 1
    // Navigation
    @Provider() pathInfos: NavPathStack = new NavPathStack()
    private titles = ['我的书架', '图书列表', '期刊列表', '实用工具', '个人中心']
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
    @Local magazinePanelActiveCategoryIndex: number = 5
    @Local magazinePanelCategories: CategoryTabItem[] = []
    @Local magazinePanelItems: MagazineListItem[] = []

    aboutToAppear(): void {
        checkToken().then(async user => {
            await saveUserInfoToPreferences(user as UserInResponse)
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
        } else if (this.activePageIndex == 3) {
            ToolPanel()
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
                value: '书架',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_square')),
                activeSymbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_square')),
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