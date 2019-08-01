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
import UserNotifications
@testable import ZendeskConnect

final class PushStrategyFactoryTests: XCTestCase {

    func testCreateSystemPush() {
        let mockAPI = MockConnectAPI()
        let factory = ConnectPushStrategyFactory()
        let mockResponse = MockNotificationResponseWrapper(isCustomNotificationAction: false                                                            ,
                                                             userInfo: ["_oid": "1234"])

        let systemPush = factory.create(response: mockResponse, connectAPI: mockAPI)
        XCTAssertTrue(type(of: systemPush) == BasicPushStrategy.self)
    }

    func testCreateSystemPushInvalidActionIdentifier() {
        let mockAPI = MockConnectAPI()
        let factory = ConnectPushStrategyFactory()
        let mockResponse = MockNotificationResponseWrapper(isCustomNotificationAction: true,
                                                             userInfo: ["_oid": "1234"])

        let noSystemPush = factory.create(response: mockResponse, connectAPI: mockAPI)
        XCTAssertTrue(type(of: noSystemPush) == HostAppPushStrategy.self)
    }

    func testCreateSystemPushInvalidInstanceID() {
        let mockAPI = MockConnectAPI()
        let factory = ConnectPushStrategyFactory()
        let mockResponse = MockNotificationResponseWrapper(isCustomNotificationAction: false,
                                                             userInfo: ["_ogp":true])

        let noSystemPush = factory.create(response: mockResponse, connectAPI: mockAPI)
        XCTAssertTrue(type(of: noSystemPush) == HostAppPushStrategy.self)
    }
}
