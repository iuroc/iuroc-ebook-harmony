import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { getToken } from '../../common/token'
import { ApiResponse } from '../Index/common/mixin'
import { MagazineListItem } from '../Index/panels/magazine/MagazinePanel'

export async function getIssues(magazineId: number, page = 0, pageSize = 72) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/magazine/issue', {
        method: http.RequestMethod.POST,
        header: {
            token: await getToken(),
            'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({ magazineId, page, pageSize }),
    })
    const result = JSON.parse(response.result as string) as ApiResponse<IssueInResponse[]>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export interface IssueInResponse {
    id: number
    issueId: string
    name: string
    cover: string
    index: number
    magazine?: MagazineListItem
}