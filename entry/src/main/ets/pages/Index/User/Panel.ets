import { clearUserPreferences } from '../../common/token'

@ComponentV2
export struct UserPanel {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        Button('退出登录').onClick(() => {
            clearUserPreferences().then(() => {
                this.pathInfos.pushPath({ name: 'Login' }, false)
            })
        })
    }
}