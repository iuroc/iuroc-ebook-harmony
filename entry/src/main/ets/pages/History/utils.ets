import { ApiResponse, BookListItemInResponse } from "../Index/common/mixin"
import { http } from "@kit.NetworkKit"
import { apiOrigin } from "../../common/config"
import { getToken } from "../../common/token"
import { InfoType } from "../Catalog/util"
import { IssueListItem } from "../Issue/Page"
import { IssueInResponse } from "../Issue/mixin"

export async function getHistories(page = 0, pageSize = 72) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/history/list', {
        method: http.RequestMethod.POST,
        header: {
            token: await getToken(),
        },
        extraData: JSON.stringify({
            page,
            pageSize
        }),
        expectDataType: http.HttpDataType.STRING
    })
    const result = JSON.parse(response.result as string) as ApiResponse<HistoryInResponse[]>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface HistoryItemInResponse {
    id: number
    itemId: number
    type: InfoType
    currentBookPage: number
    createAt: string
    userId: number
    updateAt: string
}

export interface HistoryInResponse {
    item: HistoryItemInResponse
    data: IssueInResponse | BookListItemInResponse
}


export async function deleteHistories(ids: number[]) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/history/delete', {
        method: http.RequestMethod.POST,
        header: {
            token: await getToken(),
            'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({ ids }),
    })
    const result = JSON.parse(response.result as string) as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}