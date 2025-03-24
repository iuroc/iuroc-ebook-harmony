import { http } from "@kit.NetworkKit";
import { apiOrigin } from "../../common/config";
import { getToken } from "../../common/token";
import { ApiResponse } from "../Index/common/mixin";

export async function getNotes(page: number = 0, pageSize: number = 72): Promise<NoteInResponse[]> {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/note/list', {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify({ page, pageSize }),
        header: {
            'Content-Type': 'application/json',
            token: await getToken()
        },
    })
    const result = JSON.parse(response.result as string) as ApiResponse<NoteInResponse[]>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export async function createNote(title: string, content: string): Promise<NoteInResponse> {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/note/create', {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify({ title, content }),
        header: {
            'Content-Type': 'application/json',
            token: await getToken()
        },
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<NoteInResponse>
    if (!result.success) {
        throw new Error(result.message)
    }
    result.data.title = title
    result.data.content = content
    return result.data
}

export async function updateNote(id: number, title: string, content: string): Promise<void> {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/note/edit', {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify({ id, title, content }),
        header: {
            'Content-Type': 'application/json',
            token: await getToken()
        },
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}

export async function getOneNote(id: number): Promise<NoteInResponse> {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/note/get', {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify({ id }),
        header: {
            'Content-Type': 'application/json',
            token: await getToken()
        },
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse<NoteInResponse>
    if (!result.success) {
        throw new Error(result.message)
    }
    return result.data
}

export async function deleteNote(id: number): Promise<void> {
    const request = http.createHttp()
    const response = await request.request(apiOrigin + '/api/ebook/note/delete', {
        method: http.RequestMethod.POST,
        extraData: JSON.stringify({ id }),
        header: {
            'Content-Type': 'application/json',
            token: await getToken()
        },
        expectDataType: http.HttpDataType.OBJECT
    })
    const result = response.result as ApiResponse
    if (!result.success) {
        throw new Error(result.message)
    }
}

export interface NoteNoDate {
    id: number
    title: string
    content: string
}

export interface NoteInResponse extends NoteNoDate {
    createAt: string
    updateAt: string
}