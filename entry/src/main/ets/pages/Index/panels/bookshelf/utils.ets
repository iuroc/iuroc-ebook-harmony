import { BookShelfItemInResponse, InfoType } from "../../../Catalog/util"
import { IssueInResponse } from "../../../Issue/mixin"
import { ApiResponse, BookListItemInResponse } from "../../common/mixin"
import { http } from "@kit.NetworkKit"
import { apiOrigin } from "../../../../common/config"
import { getToken } from "../../../../common/token"

export async function getBookshelfList(page = 0, pageSize = 72) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/bookShelf/list', {
        method: http.RequestMethod.POST,
        header: {
            token: await getToken(),
            'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({ page, pageSize }),
    })
    const result = JSON.parse(response.result as string) as ApiResponse<BookshelfInResponse[]>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface BookshelfInResponse {
    item: BookShelfItemInResponse
    data: IssueInResponse | BookListItemInResponse
}
