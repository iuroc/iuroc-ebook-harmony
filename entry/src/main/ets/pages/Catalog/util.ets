import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../../common/token'
import { Catalog } from '../Index/common/lib'
import { ApiResponse, BookListItemInResponse } from '../Index/common/mixin'
import { MagazineListItem } from '../Index/panels/magazine/MagazinePanel'

export async function getInfo<T extends MagazineInfoInResponse | BookInfoInResponse>(itemId: number, type: InfoType) {
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
    catalogs: Catalog[]
}

export interface MagazineInfoInResponse {
    id: number
    name: string
    cover: string
    magazine: MagazineListItem
    catalogs: Catalog[]
}

export type InfoType = 'book' | 'issue'