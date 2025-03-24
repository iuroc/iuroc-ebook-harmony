import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../../common/token'
import {
    BookInfoInResponse,
    CatalogInInfo,
    InfoType,
    IssueInfoInResponse,
    IssueInfoNoCatalogsInResponse
} from '../Catalog/util'
import { ApiResponse, BookListItemInResponse } from '../Index/common/mixin'
import { Content } from '../Index/common/lib'
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'

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
    info: IssueInfoNoCatalogsInResponse | BookListItemInResponse
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
    return (catalogs || []).filter(item => item.page && item.page <= page).slice(-1)[0]?.title
}

/**
 * 调用系统能力分享文本，并显示 Toast 提示
 * @param record 需要分享的数据
 * @throws { BusinessError } 401 - Parameter error.
 */
export async function systemShareTextWithToast(
    title: string,
    content: string
): Promise<void> {
    try {
        const sharedData = new systemShare.SharedData({
            utd: utd.UniformDataType.TEXT,
            title, content,
        })
        const controller = new systemShare.ShareController(sharedData)
        await controller.show(getContext() as common.UIAbilityContext, {
            selectionMode: systemShare.SelectionMode.SINGLE,
            previewMode: systemShare.SharePreviewMode.DETAIL,
        })
    } catch (error) {
        promptAction.showToast({ message: `分享失败：${(error as BusinessError).message}` })
    }
}

export async function getBookMarks(itemId: number, type: InfoType, page: number = 0, pageSize: number = 72) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/bookMark/list', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({
            itemId, type,
        })
    })
    const result = JSON.parse(response.result as string) as ApiResponse<BookMarkInResponse[]>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export async function toggleBookMark(title: string, bookPage: number, itemId: number, type: InfoType) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/bookMark/toggle', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({
            title,
            bookPage,
            itemId,
            type,
        })
    })
    const result = JSON.parse(response.result as string) as ApiResponse<BookMarkInResponse | null>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface BookMarkNoDate {
    id: number
    title: string
    bookPage: number
    itemId: number
    type: InfoType
}

export interface BookMarkInResponse extends BookMarkNoDate {
    updateAt: string
    createAt: string
}