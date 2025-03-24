import { MainPage } from '@iuroc/chat-page'
import { preferences, relationalStore } from '@kit.ArkData'
import { openaiConfig } from '../../common/config'

const dataPreferences = preferences.getPreferencesSync(getContext(), { name: 'chat' })
dataPreferences.putSync('openai_api_key', openaiConfig.apiKey)
dataPreferences.putSync('openai_base_url', openaiConfig.baseURL)
const getRdbStore = async () => {
    return relationalStore.getRdbStore(getContext(), {
        name: 'chat.db',
        securityLevel: relationalStore.SecurityLevel.S1
    })
}

@Builder
export function PageBuilder() {
    MainPage({
        dataPreferences,
        getRdbStore,
        defaultChatTitle: '默认对话',
        openaiCanConfig: true
    })
}