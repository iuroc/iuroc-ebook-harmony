import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../../common/token'
import { CatalogInInfo, InfoType, IssueInfoInResponse, IssueInfoNoCatalogsInResponse } from '../Catalog/util'
import { ApiResponse, BookListItemInResponse } from '../Index/common/mixin'
import { Content } from '../Index/common/lib'

export async function updateReadHistory(bookIdOrIssueId: number, type: InfoType, currentBookPage: number) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/history/update', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({ itemId: bookIdOrIssueId, type, currentBookPage }),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export async function getContentAndCatalog(itemId: number, type: InfoType, startBookPage: number,
    bookPageCount: number = 30, needCatalog = true) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/content', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({
            itemId,
            type,
            startBookPage,
            bookPageCount,
            needCatalog
        })
    })
    const result = JSON.parse(response.result as string) as ApiResponse<ContentAndCatalogInResponse>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface ContentAndCatalogInResponse {
    contents: Content[]
    catalogs: CatalogInInfo[]
}

interface GetInfoOnlyParam {
    bookId?: number
    issueId?: number
}

/**
 * @deprecated
 * @param itemId
 * @param type
 * @returns
 */
export async function getInfoOnly<T extends BookListItemInResponse | IssueInfoNoCatalogsInResponse>(itemId: number,
    type: InfoType) {
    const api = type == 'book' ? '/api/ebook/book/info/onlyInfo' : '/api/ebook/magazine/issueInfo/onlyInfo'
    const request = http.createHttp()
    const param: GetInfoOnlyParam = {}
    if (type == 'book') {
        param.bookId = itemId
    } else if (type == 'issue') {
        param.issueId = itemId
    }
    const response = await request.request(apiOrigin + api, {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify(param),
    })
    const result = JSON.parse(response.result as string) as ApiResponse<T>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}


export function makePageHTML(content: string) {
    return `
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            img {
                max-width: 100% !important;
                height: auto !important;
            }

            body {
                margin: 0;
                letter-spacing: 1px;
                line-height: 1.5;
                text-align: justify;
            }
        </style>
    </head>

    <body>
        <div style="padding: 0 15px 70px;">
            ${content}
        </div>
    </body>

    </html>`
}

export function getCatalogTitleByBookPage(page: number, catalogs: CatalogInInfo[]) {
    return (catalogs || []).filter(item => item.page <= page).slice(-1)[0].title
}