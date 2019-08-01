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

final class BasicPushStrategyTests: XCTestCase {

    func testHandleSystemPush() {
        let userInfo: [AnyHashable: Any] = ["_oid": "1234"]
        let mockAPI = MockConnectAPI()
        let mockResponse = MockNotificationResponseWrapper(isCustomNotificationAction: false, userInfo: userInfo)
        let systemPush = BasicPushStrategy(response: mockResponse, connectAPI: mockAPI)

        XCTAssertFalse(mockAPI.opened)

        systemPush.handleNotification { }
        XCTAssertTrue(mockAPI.opened)
    }
}
