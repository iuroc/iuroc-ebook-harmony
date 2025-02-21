import { preferences } from '@kit.ArkData'
import { http } from '@kit.NetworkKit'
import { apiOrigin } from './config'
import { ApiResponse } from '../pages/Index/common/mixin'

export async function getUserPreferences() {
    return preferences.getPreferences(getContext(), { name: 'user' })
}

export async function getToken() {
    const data = await getUserPreferences()
    const token = await data.get('token', '')
    return typeof token == 'string' ? token : ''
}

export async function saveToken(token: string) {
    const data = await getUserPreferences()
    await data.put('token', token)
    await data.flush()
}

export class TokenError extends Error {
}

export async function checkToken() {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/user/checkToken', {
        method: http.RequestMethod.POST,
        header: { token: await getToken() },
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<UserInPreferences>
    if (!result.success) {
        throw new TokenError(result.message)
    }
    return result.data
}

/**
 * 保存用户信息
 * @param user
 */
export async function saveUserInfoToPreferences(user: UserInPreferences) {
    const data = await getUserPreferences()
    await data.put('id', user.id)
    await data.put('username', user.username)
    await data.put('createAt', user.createAt)
    await data.flush()
}

/**
 * 获取用户信息
 * @returns
 */
export async function getUseInfoFromPreferences() {
    const data = await getUserPreferences()
    const id = await data.get('id', '')
    const username = await data.get('username', '')
    const createAt = await data.get('createAt', '')
    return {
        id,
        username,
        createAt,
    } as UserInPreferences
}

export interface UserInPreferences {
    id: number
    username: string
    createAt: string
}

export async function clearUserPreferences() {
    const data = await getUserPreferences()
    await data.clear()
    await data.flush()
}

export interface UserInResponse extends UserInPreferences {}