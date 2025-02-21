import { http } from '@kit.NetworkKit'
import { apiOrigin } from '../../common/config'
import { ApiResponse } from '../Index/common/mixin'
import { UserInPreferences } from '../../common/token'

/**
 * 登录和注册聚合接口，完成后请调用 `saveUserToPreferences` 和 `saveToken` 保存用户信息和令牌
 * @param username 用户名
 * @param password 密码
 * @returns 用户信息和令牌
 */
export async function loginOrRegister(username: string, password: string): Promise<LoginResult> {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/user/loginOrRegister', {
        method: http.RequestMethod.POST,
        header: {
            'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({ username, password }),
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<LoginResult>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

interface LoginResult {
    user: UserInPreferences
    token: string
}


