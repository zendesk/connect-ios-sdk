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

final class SilentPushStrategyFactoryTests: XCTestCase {

    func testCreateUninstallTracker() {
        let mockAPI = MockConnectAPI()
        let factory = ConnectSilentPushStrategyFactory(coordinator: IPMCoordinator(connectAPI: mockAPI))

        let uninstallTracker = factory.create(userInfo: ["_ogp": true], connectAPI: mockAPI)
        XCTAssertTrue(type(of: uninstallTracker) == UninstallSilentPushStrategy.self)
    }

    func testCreateDefaultSilentPushType() {
        let mockAPI = MockConnectAPI()
        let factory = ConnectSilentPushStrategyFactory(coordinator: IPMCoordinator(connectAPI: mockAPI))

        let defaultStrategy = factory.create(userInfo: ["_ogp": false], connectAPI: mockAPI)
        XCTAssertTrue(type(of: defaultStrategy) == DefaultSilentPushStrategy.self)
    }

    func testCreateIPMSilentPushType() {
        let mockAPI = MockConnectAPI()
        let factory = ConnectSilentPushStrategyFactory(coordinator: IPMCoordinator(connectAPI: mockAPI))

        let ipmStrategy = factory.create(userInfo: ["type": "ipm"], connectAPI: mockAPI)
        XCTAssertTrue(type(of: ipmStrategy) == IPMSilentPushStrategy.self)
    }
}
