import { http } from "@kit.NetworkKit";
import { apiOrigin } from "../../../../common/config";
import { getToken } from "../../../../common/token";
import { ApiResponse } from "../../common/mixin";

export async function deleteUser(): Promise<void> {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/user/delete', {
        method: http.RequestMethod.POST,
        header: {
            token: await getToken()
        },
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}