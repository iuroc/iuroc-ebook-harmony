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
import { preferences, uniformTypeDescriptor as utd } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { SettingOptionObservedV2, themeGroup } from './WebReadBox'
import { webview } from '@kit.ArkWeb'

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


export function makePageHTML(content: string, settingOption: SettingOptionObservedV2) {
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
                letter-spacing: ${settingOption.cssLetterSpacing};
                line-height: ${settingOption.cssLineHeight};
                text-align: justify;
                font-size: ${settingOption.cssFontSize};
                color: ${themeGroup[settingOption.themeIndex].fontColor};
                background-color: ${themeGroup[settingOption.themeIndex].backgroundColor};
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
    if (result.data) {
        result.data.title = title
        result.data.bookPage = bookPage
        result.data.itemId = itemId
        result.data.type = type
    }
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

/**
 * 从用户首选项加载阅读设置项
 */
export function loadReadSetting() {
    const data = preferences.getPreferencesSync(getContext(), { name: 'ReadSetting' })
    const option = new SettingOptionObservedV2()
    option.cssFontSize = data.getSync('cssFontSize', '16px') as string
    option.cssLineHeight = data.getSync('cssLineHeight', '1.5') as string
    option.cssLetterSpacing = data.getSync('cssLetterSpacing', '1px') as string
    option.themeIndex = data.getSync('themeIndex', 0) as number
    return option
}

/**
 * 保存阅读设置项到用户首选项
 * @param option
 */
export function saveReadSetting(option: SettingOptionObservedV2) {
    const data = preferences.getPreferencesSync(getContext(), { name: 'ReadSetting' })
    data.putSync('cssFontSize', option.cssFontSize)
    data.putSync('cssLineHeight', option.cssLineHeight)
    data.putSync('cssLetterSpacing', option.cssLetterSpacing)
    data.putSync('themeIndex', option.themeIndex)
    data.flush()
}

export function updateWebSetting(controller: webview.WebviewController, setting: SettingOptionObservedV2) {
    const theme = themeGroup[setting.themeIndex]
    controller.runJavaScript(`document.body.style.color = '${theme.fontColor}'`)
    controller.runJavaScript(`document.body.style.backgroundColor = '${theme.backgroundColor}'`)
    controller.runJavaScript(`document.body.style.fontSize = '${setting.cssFontSize}'`)
    controller.runJavaScript(`document.body.style.lineHeight = '${setting.cssLineHeight}'`)
    controller.runJavaScript(`document.body.style.letterSpacing = '${setting.cssLetterSpacing}'`)
}