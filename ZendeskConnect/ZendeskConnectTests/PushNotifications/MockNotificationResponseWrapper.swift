/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import XCTest
@testable import ZendeskConnect

final class MockNotificationResponseWrapper: NotificationResponseWrapper {
    private var _isCustomNotificationAction: Bool

    private let _userInfo: [AnyHashable: Any]

    init(isCustomNotificationAction: Bool, userInfo: [AnyHashable: Any]) {
        self._isCustomNotificationAction = isCustomNotificationAction
        self._userInfo = userInfo
    }

    var isCustomNotificationAction: Bool {
        return _isCustomNotificationAction
    }

    var userInfo: [AnyHashable : Any] {
        return _userInfo
    }
}
