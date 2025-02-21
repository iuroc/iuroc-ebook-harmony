export function replaceChinesePunctuation(input: string): string {
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