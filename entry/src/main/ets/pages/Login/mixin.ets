import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../common/config'
import { url } from '@kit.ArkTS'
import { ApiResponse } from '../Index/common/mixin'

export async function loginOrRegister(username: string, password: string) {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/user/loginOrRegister', {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify({ username, password }),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<>
}

interface LoginResult {
    user: User
}
