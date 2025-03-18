import { clearUserPreferences } from '../../../../common/token'
import { ComposeListItem, IconType } from '@ohos.arkui.advanced.ComposeListItem'
import { BSColor } from '@iuroc/bootstrap5-color'
import { deleteUser } from './utils'
import { IconStyle, promptAction } from '@kit.ArkUI'

@ComponentV2
export struct UserPanel {
    @Consumer() pathInfos: NavPathStack = new NavPathStack()

    build() {
        List() {
            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '阅读笔记',
                        secondaryText: '包含您的阅读摘录和个人笔记',
                        iconStyle: IconType.HEAD_SCULPTURE,
                        icon: $r('app.media.note_blue')
                    }
                })
                    .onClick(() => {
                        this.pathInfos.pushPath({ name: 'Note' })
                    })
            }

            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '退出登录',
                        secondaryText: '您的云端数据不会被删除',
                        iconStyle: IconType.HEAD_SCULPTURE,
                        icon: $r('app.media.logout')
                    }
                }).onClick(() => {
                    AlertDialog.show({
                        title: '退出登录',
                        message: '确定要退出登录吗？（你的云端数据不会被删除）',
                        buttons: [
                            {
                                value: '确定退出',
                                fontColor: BSColor.danger,
                                action: () => {
                                    clearUserPreferences().then(() => {
                                        this.pathInfos.pushPath({ name: 'Login' }, false)
                                    })
                                }
                            },
                            {
                                value: '取消',
                                fontColor: BSColor.dark,
                                action: () => {

                                }
                            }
                        ]
                    })
                })
            }

            ListItem() {
                ComposeListItem({
                    contentItem: {
                        primaryText: '注销账号',
                        secondaryText: '彻底删除您的账号和云端数据',
                        iconStyle: IconType.HEAD_SCULPTURE,
                        icon: $r('app.media.delete_user')
                    }
                }).onClick(() => {
                    AlertDialog.show({
                        title: '注销账号',
                        message: '确定要注销账号吗？（这是一个危险操作，你的云端数据将被删除）',
                        buttons: [
                            {
                                value: '确定注销',
                                fontColor: BSColor.danger,
                                action: () => {
                                    deleteUser().then(() => {
                                        this.pathInfos.pushPath({ name: 'Login' }, false)
                                    }).catch((error: Error) => {
                                        promptAction.showToast(error)
                                    })
                                }
                            },
                            {
                                value: '取消',
                                fontColor: BSColor.dark,
                                action: () => {

                                }
                            }
                        ]
                    })
                })
            }
        }
        .padding({ left: 10, right: 10, bottom: 10 })
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
}