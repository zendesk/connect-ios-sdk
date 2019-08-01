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
@testable import ZendeskConnect

class TestDelegate: PushRegistrationDelegate {

    var alertDisplayed = false
    var requested = false

    func showPrePermissionAlert(prePrompt: PrePrompt) {
        alertDisplayed = true
    }
    
    func requestAuthorization() {
        requested = true
    }
}

class PushRegistrationControllerTests: XCTestCase {

    func testPrompWithoutPrePermissionsAlert() {
        let delegate = TestDelegate()
        let pushManager = ConnectPushRegistration()
        pushManager.delegate = delegate

        let config = Config(enabled: true, account: AccountConfig(prompt: true, promptEvent: nil, prePrompt: nil))

        pushManager.attemptAfterIdentify(configuration: config)
        XCTAssert(delegate.requested)
        XCTAssertFalse(delegate.alertDisplayed)
    }

    func testPrompPrePermissionsAlert() {
        let delegate = TestDelegate()
        let pushManager = ConnectPushRegistration()
        pushManager.delegate = delegate

        let config = Config(enabled: true,
                            account: AccountConfig(prompt: true,
                                                   promptEvent: nil,
                                                   prePrompt: PrePrompt(title: nil,
                                                                        body: nil,
                                                                        noButton: nil,
                                                                        yesButton: nil)))

        pushManager.attemptAfterIdentify(configuration: config)
        XCTAssertFalse(delegate.requested)
        XCTAssert(delegate.alertDisplayed)
    }

    func testCantPrePromptTwicePerRun() {
        let delegate = TestDelegate()
        let pushManager = ConnectPushRegistration()
        pushManager.delegate = delegate

        let config = Config(enabled: true,
                            account: AccountConfig(prompt: true,
                                                   promptEvent: nil,
                                                   prePrompt: PrePrompt(title: nil,
                                                                        body: nil,
                                                                        noButton: nil,
                                                                        yesButton: nil)))

        pushManager.attemptAfterIdentify(configuration: config)
        XCTAssertFalse(delegate.requested)
        XCTAssert(delegate.alertDisplayed)

        delegate.alertDisplayed = false

        pushManager.attemptAfterIdentify(configuration: config)
        XCTAssertFalse(delegate.requested)
        XCTAssertFalse(delegate.alertDisplayed)
    }

    func testPrompWithoutPrePermissionsAlertAtAnEventMatch() {
        let delegate = TestDelegate()
        let pushManager = ConnectPushRegistration()
        pushManager.delegate = delegate

        let config = Config(enabled: true, account: AccountConfig(prompt: true, promptEvent: "test", prePrompt: nil))

        pushManager.attemptAfter(event: "test", configuration: config)
        XCTAssert(delegate.requested)
        XCTAssertFalse(delegate.alertDisplayed)
    }

    func testPrompPrePermissionsAlertAtAnEventMatch() {
        let delegate = TestDelegate()
        let pushManager = ConnectPushRegistration()
        pushManager.delegate = delegate

        let config = Config(enabled: true,
                            account: AccountConfig(prompt: true,
                                                   promptEvent: "test",
                                                   prePrompt: PrePrompt(title: nil,
                                                                        body: nil,
                                                                        noButton: nil,
                                                                        yesButton: nil)))

        pushManager.attemptAfter(event: "test", configuration: config)
        XCTAssertFalse(delegate.requested)
        XCTAssert(delegate.alertDisplayed)
    }

    func testPrompWithoutPrePermissionsAlertAtAnEventNoMatch() {
        let delegate = TestDelegate()
        let pushManager = ConnectPushRegistration()
        pushManager.delegate = delegate

        let config = Config(enabled: true, account: AccountConfig(prompt: true, promptEvent: "test", prePrompt: nil))

        pushManager.attemptAfter(event: "test-1-2", configuration: config)
        XCTAssertFalse(delegate.requested)
        XCTAssertFalse(delegate.alertDisplayed)
    }

    func testPrompPrePermissionsAlertAtAnEventNoMatch() {
        let delegate = TestDelegate()
        let pushManager = ConnectPushRegistration()
        pushManager.delegate = delegate

        let config = Config(enabled: true,
                            account: AccountConfig(prompt: true,
                                                   promptEvent: "test",
                                                   prePrompt: PrePrompt(title: nil,
                                                                        body: nil,
                                                                        noButton: nil,
                                                                        yesButton: nil)))

        pushManager.attemptAfter(event: "test-1-2", configuration: config)
        XCTAssertFalse(delegate.requested)
        XCTAssertFalse(delegate.alertDisplayed)
    }
}
