import { fileIo, fileUri } from "@kit.CoreFileKit"
import { request } from "@kit.BasicServicesKit"
import { uniformTypeDescriptor } from "@kit.ArkData"

export function replaceChinesePunctuation(input = ''): string {
    const punctuationMap: Record<string, string> = {
        '，': ',',
        '。': '.',
        '；': ';',
        '：': ':',
        '？': '?',
        '！': '!',
        '“': '"',
        '”': '"',
        '‘': "'",
        '’': "'",
        '【': '[',
        '】': ']',
        '（': '(',
        '）': ')',
        '——': '--',
        '…': '...',
        '《': '<',
        '》': '>',
    }
    return input.replace(/[，。；：？！“”‘’【】（）——…《》]/g, match => punctuationMap[match] || match)
}
/**
 * 根据文件后缀查询 Mime 类型
 * @param extention 文件后缀，以 . 开头
 * @returns MimeType
 */
export function extToMime(extention: string) {
    const typeId = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(extention)
    const typeObj = uniformTypeDescriptor.getTypeDescriptor(typeId)
    const mimeTypes = typeObj.mimeTypes
    return mimeTypes
}

/**
 * 根据路径或 uri 获取后缀，以 . 开头
 * @param path
 * @returns
 */
export function extname(path: string) {
    return path.substring(path.lastIndexOf('.'))
}

/**
 * 获取网络图片的本地预览路径
 * @param url
 * @returns
 */
export function getPreviewFileUriForImageURL(url: string) {
    return new Promise<string>((resolve, reject) => {
        const filePath = getContext().filesDir + '/' + url.replaceAll(/[\/:]/g, '')
        if (!fileIo.accessSync(filePath)) {
            request.downloadFile(getContext(), {
                url: url,
                filePath
            }).then(task => {
                task.on('complete', () => {
                    resolve(fileUri.getUriFromPath(filePath))
                })
                task.on('fail', error => {
                    reject(new Error(error.toString()))
                })
            })
        } else {
            resolve(fileUri.getUriFromPath(filePath))
        }
    })
}