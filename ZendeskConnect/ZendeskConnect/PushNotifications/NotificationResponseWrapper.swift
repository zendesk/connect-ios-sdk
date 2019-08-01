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

protocol NotificationResponseWrapper {
    var userInfo: [AnyHashable: Any] { get }
    var isCustomNotificationAction: Bool { get }
}

final class ConnectNotificationResponse: NotificationResponseWrapper {
    private let response: UNNotificationResponse

    init(response: UNNotificationResponse) {
        self.response = response
    }
    
    var isCustomNotificationAction: Bool {
        return response.actionIdentifier != UNNotificationDefaultActionIdentifier
    }

    var userInfo: [AnyHashable : Any] {
        return response.notification.request.content.userInfo
    }
}
