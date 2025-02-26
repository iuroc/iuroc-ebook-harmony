import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../../common/token'
import { InfoType } from '../Catalog/util'
import { ApiResponse } from '../Index/common/mixin'

export async function getOneReadHistory(itemId: number, type: InfoType) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/history/update', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        extraData: JSON.stringify({ itemId, type }),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<ReadHistoryInResponse>
    if (!result.success) {
        throw new Error(result.message)
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