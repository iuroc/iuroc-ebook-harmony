import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../../common/token'
import { Catalog } from '../Index/common/lib'
import { ApiResponse, BookListItemInResponse } from '../Index/common/mixin'
import { MagazineListItem } from '../Index/panels/magazine/MagazinePanel'

export async function getInfo<T extends IssueInfoInResponse | BookInfoInResponse>(itemId: number, type: InfoType) {
    const request = http.createHttp()
    const _url = apiOrigin + (type == 'book' ? '/api/ebook/book/info' : '/api/ebook/magazine/issueInfo')
    const response = await request.request(_url, {
        method: http.RequestMethod.POST,
        header: {
            token: await getToken(),
            'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(type == 'book' ? {
            bookId: itemId
        } : {
            issueId: itemId
        })
    })
    const result = JSON.parse(response.result as string) as ApiResponse<T>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface BookInfoInResponse extends BookListItemInResponse {
    catalogs: CatalogInInfo[]
}

export interface IssueInfoNoCatalogsInResponse {
    id: number
    name: string
    cover: string
    magazine: MagazineListItem
}

export interface IssueInfoInResponse extends IssueInfoNoCatalogsInResponse {
    catalogs: Catalog[]
}

export type InfoType = 'book' | 'issue'

@ObservedV2
export class CatalogObservedV2 {
    @Trace page: number
    @Trace title: string
    @Trace level: number

    constructor(page: number, title: string, level: number) {
        this.page = page
        this.title = title
        this.level = level
    }
}

export interface CatalogInInfo {
    page: number
    title: string
    index: number
    parentId: number
    id: number
    level: number
}

export async function getOneBookShelf(itemId: number, type: InfoType) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/bookShelf/get', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({ itemId, type }),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<BookShelfInResponse>
    if (!result.success) {
        return false
    }
    return result.data
}

export async function toggleBookShelf(itemId: number, type: InfoType) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/bookShelf/toggle', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({ itemId, type }),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<BookShelfToggleResultInResponse>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface BookShelfInResponse {
    id: number
    itemId: number
    type: InfoType
    userId: number
    createAt: string
}

export interface BookShelfToggleResultInResponse {
    isInBookShelf: boolean
}

export interface BookShelfAddResultInResponse extends BookShelfToggleResultInResponse {
    id: number
    createAt: string
}

export async function getOneReadHistory(itemId: number, type: InfoType) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/history/get', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({ itemId, type }),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<ReadHistoryInResponse>
    if (!result.success) {
        return false
    }
    return result.data
}

export interface ReadHistoryInResponse {
    id: number
    itemId: number
    type: InfoType
    currentBookPage: number
    createAt: string
    userId: number
    updateAt: string
}