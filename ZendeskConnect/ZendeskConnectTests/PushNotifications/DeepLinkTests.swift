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

final class DeepLinkTests: XCTestCase {

    func testWithNoDeepLinkInInfoDict() {
        let mockDeepLinkHandler = MockDeepLinkHandler()

        DeepLink.handleDeepLink(in: [:], with: mockDeepLinkHandler)
        XCTAssertFalse(mockDeepLinkHandler.canOpen)
    }

    func testWithLinkThatAppCanNotOpen() {
        let mockDeepLinkHandler = MockDeepLinkHandler()
        mockDeepLinkHandler.canOpenURL = false

        DeepLink.handleDeepLink(in: ["_odl":"https://url.fake"], with: mockDeepLinkHandler)
        XCTAssertFalse(mockDeepLinkHandler.canOpen)
    }

    func testWithLinkThatAppCanOpen() {
        let mockDeepLinkHandler = MockDeepLinkHandler()
        mockDeepLinkHandler.canOpenURL = true

        DeepLink.handleDeepLink(in: ["_odl":"https://url.fake"], with: mockDeepLinkHandler)
        XCTAssertTrue(mockDeepLinkHandler.canOpen)
    }
}
