import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../../common/config'
import { getToken } from '../../../common/token'
import { BookListItem } from '../panels/book/BookPanel'
import { MagazineListItem } from '../panels/magazine/MagazinePanel'

export async function getCategories(type: EbookType) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/category', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        extraData: JSON.stringify({ type }),
        header: {
            token: await getToken(),
            'Content-Type': 'application/json'
        }
    })
    const result = response.result as ApiResponse<CategoryInResponse[]>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export type EbookType = 'book' | 'magazine'

export interface CategoryInResponse {
    id: number
    type: EbookType
    name: string
}

/** API响应格式 */
export interface ApiResponse<T = null> {
    success: boolean
    data: T
    message: string
}

export function makeImageSrc(src: string) {
    return src.startsWith('/') ? (apiOrigin + src) : src
}

export async function getItems<T extends BookListItemInResponse | MagazineItemInResponse>(
    categoryId: number = -1,
    page = 0,
    pageSize = 72,
    keyword = ''
) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/item', {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify({
            categoryId: categoryId == -1 ? undefined : categoryId,
            page,
            pageSize,
            keyword
        }),
        header: {
            token: await getToken(),
            'Content-Type': 'application/json'
        }
    })
    const result = JSON.parse(response.result as string) as ApiResponse<T[]>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface CommonListItem {
    id: number
    name: string
    /** 内容介绍 */
    summary: string
    /** 普通封面 */
    cover: string
}

export interface BookListItemInResponse extends BookListItem {
    type: 'book'
}

export interface MagazineItemInResponse extends MagazineListItem {
    type: 'magazine'
}
