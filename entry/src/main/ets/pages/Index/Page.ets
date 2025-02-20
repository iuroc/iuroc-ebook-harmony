import { SymbolGlyphModifier } from '@kit.ArkUI'
import { BookListItem, BookPanel, CategoryTabItem } from './Book/Panel'
import { RecommendPanel } from './Recommend/Panel'

@Entry
@ComponentV2
struct Page {
    @Local activePageIndex: number = 1
    // Navigation
    private titles = ['精彩推荐', '图书列表', '期刊列表', '实用工具', '个人中心']
    private titleModes: NavigationTitleMode[] = [
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
        NavigationTitleMode.Mini,
    ]
    // RecommendPanel
    @Local recommendPanelNeedInit: boolean = true
    // BookPanel
    @Local bookPanelNeedInit: boolean = true
    @Local bookPanelActiveIndex: number = 0
    @Local bookPanelCategories: CategoryTabItem[] = []
    @Local bookPanelBooks: BookListItem[] = []

    aboutToAppear(): void {

    }

    build() {
        Navigation() {
            if (this.activePageIndex == 0) {
                RecommendPanel()
            } else if (this.activePageIndex == 1) {
                BookPanel({
                    needInit: this.bookPanelNeedInit,
                    activeIndex: this.bookPanelActiveIndex,
                    categories: this.bookPanelCategories,
                    changeNeedInit: value => this.bookPanelNeedInit = value,
                    changeActiveIndex: value => this.bookPanelActiveIndex = value,
                    books: this.bookPanelBooks,
                })
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
        .toolbarConfiguration([
            {
                value: '推荐',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.label')),
                action: () => {
                    this.activePageIndex = 0
                }
            },
            {
                value: '图书',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.book')),
                action: () => {
                    this.activePageIndex = 1
                }
            },
            {
                value: '期刊',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.list_square_bill')),
                action: () => {
                    this.activePageIndex = 2
                }
            },
            {
                value: '工具',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.more')),
                action: () => {
                    this.activePageIndex = 3
                }
            },
            {
                value: '我的',
                symbolIcon: new SymbolGlyphModifier($r('sys.symbol.person')),
                action: () => {
                    this.activePageIndex = 4
                }
            }
        ])
    }
}