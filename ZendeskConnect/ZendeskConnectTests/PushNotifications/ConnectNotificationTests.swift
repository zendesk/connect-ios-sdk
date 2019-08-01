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

final class ConnectNotificationTests: XCTestCase {

    func testIsConnectPushUtil() {

        XCTAssertFalse(ConnectNotification.isConnectNotification(userInfo: [:]))
        XCTAssertTrue(ConnectNotification.isConnectNotification(userInfo: ["_oid":1287]))
    }

    func testIsUninstallTrackerUtil() {

        XCTAssertFalse(ConnectNotification.isUninstallTracker(userInfo: [:]))
        XCTAssertFalse(ConnectNotification.isUninstallTracker(userInfo: ["_ogp":false]))
        XCTAssertFalse(ConnectNotification.isUninstallTracker(userInfo: ["_ogp":"true"]))
        XCTAssertTrue(ConnectNotification.isUninstallTracker(userInfo: ["_ogp":true]))
    }

    func testIsSilentPushUtil() {

        XCTAssertFalse(ConnectNotification.isQuietPush(userInfo: [:]))
        XCTAssertFalse(ConnectNotification.isQuietPush(userInfo: ["_oq":false]))
        XCTAssertFalse(ConnectNotification.isQuietPush(userInfo: ["_oq":"true"]))
        XCTAssertTrue(ConnectNotification.isQuietPush(userInfo: ["_oq":true]))
    }

    func testIsIPM() {

        XCTAssertFalse(ConnectNotification.isIPM(userInfo: [:]))
        XCTAssertFalse(ConnectNotification.isIPM(userInfo: ["_oid":1234]))
        XCTAssertFalse(ConnectNotification.isIPM(userInfo: ["type":"push"]))
        XCTAssertTrue(ConnectNotification.isIPM(userInfo: ["type":"ipm"]))
    }

    func testInstanceIDValue() {

        XCTAssertNil(ConnectNotification.instanceIDValue(userInfo: [:]))
        XCTAssertNil(ConnectNotification.instanceIDValue(userInfo: ["_oid":true]))
        XCTAssertNil(ConnectNotification.instanceIDValue(userInfo: ["_oid":1234]))
        XCTAssertNil(ConnectNotification.instanceIDValue(userInfo: ["_odl":"1234"]))
        XCTAssertEqual(ConnectNotification.instanceIDValue(userInfo: ["_oid":"1234"]), "1234")
    }

    func testDeepLinkValue() {

        XCTAssertNil(ConnectNotification.deepLinkValue(userInfo: [:]))
        XCTAssertNil(ConnectNotification.deepLinkValue(userInfo: ["_odl":true]))
        XCTAssertNil(ConnectNotification.deepLinkValue(userInfo: ["_odl":1234]))
        XCTAssertNil(ConnectNotification.deepLinkValue(userInfo: ["_oid":"url://deepLink"]))
        XCTAssertEqual(ConnectNotification.deepLinkValue(userInfo: ["_odl":"url://deepLink"]), "url://deepLink")
    }
}
