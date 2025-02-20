import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'

export async function getCategories(type: EbookType) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/category', {
        method: http.RequestMethod.POST,
        expectDataType: http.HttpDataType.OBJECT,
        extraData: JSON.stringify({ type }),
        header: {
            token: 'eyJhbGciOiJIUzI1NiJ9.Nw.IJKx-b6YX4YDnkHSDaoz8J22W_g_1Qu3LTfYmm-7uvo'
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

export function getItems(categoryId: number, page = 0, pageSize = 72) {

}