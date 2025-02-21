import { CommonListItem } from '../common/mixin'

export interface MagazineListItem extends CommonListItem {
    /** 国内刊号 */
    cn: string
    /** 国际刊号 */
    issn: string
}

@ComponentV2
export struct MagazinePanel {
    build() {

    }
}