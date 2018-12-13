/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
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

final class MockConnectAPI: ConnectAPI {

    var tracked = false
    var received = false
    var opened = false

    func register(_ token: Data, for userId: String) {}

    func disable(_ token: Data, for userId: String) {}

    func flush(_ eventQueue: Queue<Event>) {}

    func flush(_ identifyQueue: Queue<User>) {}

    func track(uninstall: UninstallTracker, completion: PushProviderCompletion?) { tracked = true }

    func send(received metric: PushBasicMetric, completion: PushProviderCompletion?) { received = true }

    func send(opened metric: PushBasicMetric, completion: PushProviderCompletion?) { opened = true }

    func testSend(code: Int, deviceToken: Data, completion: @escaping (Bool) -> Void) {}
}

final class MockDeepLinkHandler: DeepLinkHandler {

    var iOS10Open = false
    var iOS9Open = false

    var canOpenURL = false

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
        iOS10Open = true
    }

    func openURL(_ url: URL) -> Bool {
        iOS9Open = true
        return true
    }

    func canOpenURL(_ url: URL) -> Bool {
        return canOpenURL
    }
}

class ConnectPushNotificationHandlerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConnectDisabledDoesNotCallAPI() {

        let mockAPI = MockConnectAPI()
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        // is a connect push, but connect is disabled.
        handler.handleNotification(userInfo: ["_oid": 12342131 ], configuration: Config(enabled: false, account: nil), completion: { _ in })

        XCTAssertFalse(mockAPI.tracked)
    }

    func testNonConnectNotificationDoesNotCallAPI() {

        let mockAPI = MockConnectAPI()
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        // connect is enabled, but there is no connect push id.
        handler.handleNotification(userInfo: [:], configuration: Config(enabled: true, account: nil), completion: { _ in })

        XCTAssertFalse(mockAPI.tracked)
    }

    func testWithNoDeepLinkInInfoDict() {

        let mockAPI = MockConnectAPI()
        let mockDeepLinkHandler = MockDeepLinkHandler()
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        handler.handleDeepLink(in: [:], with: mockDeepLinkHandler)

        if #available(iOS 10.0, *) {
            XCTAssertFalse(mockDeepLinkHandler.iOS10Open)
        } else {
            XCTAssertFalse(mockDeepLinkHandler.iOS9Open)
        }
    }

    func testWithLinkThatAppCanNotOpen() {

        let mockAPI = MockConnectAPI()
        let mockDeepLinkHandler = MockDeepLinkHandler()
        mockDeepLinkHandler.canOpenURL = false
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        handler.handleDeepLink(in: ["_odl":"https://url.fake"], with: mockDeepLinkHandler)

        if #available(iOS 10.0, *) {
            XCTAssertFalse(mockDeepLinkHandler.iOS10Open)
        } else {
            XCTAssertFalse(mockDeepLinkHandler.iOS9Open)
        }
    }

    func testWithLinkThatAppCanOpen() {

        let mockAPI = MockConnectAPI()
        let mockDeepLinkHandler = MockDeepLinkHandler()
        mockDeepLinkHandler.canOpenURL = true
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        handler.handleDeepLink(in: ["_odl":"https://url.fake"], with: mockDeepLinkHandler)

        if #available(iOS 10.0, *) {
            XCTAssertTrue(mockDeepLinkHandler.iOS10Open)
        } else {
            XCTAssertTrue(mockDeepLinkHandler.iOS9Open)
        }
    }

    func testIsConnectPushUtil() {

        let mockAPI = MockConnectAPI()
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        XCTAssertFalse(handler.isConnectNotification(userInfo: [:]))
        XCTAssertTrue(handler.isConnectNotification(userInfo: ["_oid":1287]))
    }

    func testIsUninstallTrackerUtil() {

        let mockAPI = MockConnectAPI()
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        XCTAssertFalse(handler.isUninstallTracker(userInfo: [:]))
        XCTAssertFalse(handler.isUninstallTracker(userInfo: ["_ogp":false]))
        XCTAssertFalse(handler.isUninstallTracker(userInfo: ["_ogp":"true"]))

        XCTAssertTrue(handler.isUninstallTracker(userInfo: ["_ogp":true]))
    }

    func testIsSilentPushUtil() {

        let mockAPI = MockConnectAPI()
        let handler = ConnectPushNotificationHandler(connectClient: mockAPI)

        XCTAssertFalse(handler.isSilentPush(userInfo: [:]))
        XCTAssertFalse(handler.isSilentPush(userInfo: ["_oq":false]))
        XCTAssertFalse(handler.isSilentPush(userInfo: ["_oq":"true"]))

        XCTAssertTrue(handler.isSilentPush(userInfo: ["_oq":true]))
    }


}
