import { promptAction, window } from '@kit.ArkUI'
import { saveToken, saveUserInfoToPreferences as saveUserToPreferences, UserInResponse } from '../../common/token'
import { loginOrRegister } from './mixin'

@ComponentV2
struct Page {
    @Local i_username: string = 'hello'
    @Local i_password: string = '12345678abc'
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        Scroll() {
            Column({ space: 15 }) {
                Column({ space: 5 }) {
                    Text('格式要求 4-30 位数字、字母、下划线组合').fontSize(10).width('100%').padding({ left: 15 })
                    TextInput({ placeholder: '请输入账号', text: $$this.i_username })
                        .border({
                            width: 1,
                            color: this.i_username.length == 0 || this.checkUsername() ? Color.Transparent :
                            Color.Red
                        })
                }

                Column({ space: 5 }) {
                    Text('格式要求 10-30 位任意字符').fontSize(10).width('100%').padding({ left: 15 })
                    TextInput({ placeholder: '请输入密码', text: $$this.i_password })
                        .type(InputType.Password)
                        .border({
                            width: 1,
                            color: this.i_password.length == 0 || this.checkPassword() ? Color.Transparent :
                            Color.Red
                        })
                        .id('input-password')
                }

                Button('登录 / 注册').width('100%')
                    .enabled(this.checkUsername() && this.checkPassword())
                    .onClick(() => {
                        loginOrRegister(this.i_username, this.i_password, true).then(async result => {
                            await saveUserToPreferences(result.user)
                            await saveToken(result.token)
                            this.pathInfos.pop({}, false)
                        }).catch((error: Error) => {
                            promptAction.showToast(error)
                        })
                    })
            }
            .width('100%')
        }
        .height('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding(15)
    }

    checkUsername() {
        return !!this.i_username.match(/^\w{4,30}$/)
    }

    checkPassword() {
        return !!this.i_password.match(/^\S{10,30}$/)
    }
}

@Builder
export function PageBuilder() {
    NavDestination() {
        Page()
    }
    .title('用户登录')
    .onBackPressed(() => {
        window.getLastWindow(getContext()).then(lastWindow => {
            lastWindow.minimize()
        })
        return true
    })
}