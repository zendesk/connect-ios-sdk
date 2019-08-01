/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation
import UserNotifications

protocol PushStrategyFactory {
    func create(response: NotificationResponseWrapper, connectAPI: ConnectAPI) -> PushStrategy
}

final class ConnectPushStrategyFactory: PushStrategyFactory {
    func create(response: NotificationResponseWrapper, connectAPI: ConnectAPI) -> PushStrategy {
        
        if response.isCustomNotificationAction ||
            ConnectNotification.isHostAppNotification(userInfo: response.userInfo) {
            return HostAppPushStrategy()
        }
        
        return BasicPushStrategy(response: response, connectAPI: connectAPI)
    }
}
