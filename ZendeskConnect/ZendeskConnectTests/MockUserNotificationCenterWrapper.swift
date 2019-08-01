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

final class MockUserNotificationCenterWrapper: UserNotificationCenterWrapper {

    private var _authorizationStatus: UNAuthorizationStatus

    var authorizationStatus: UNAuthorizationStatus {
        get {
            authorizationStatusExpectation.fulfill()
            return _authorizationStatus
        }
    }

    private let _hasDelivered: Bool
    func hasDelivered(oid: String) -> Bool {
        deliveredExpectation.fulfill()
        return _hasDelivered
    }

    private let removeExpectation: XCTestExpectation
    private let authorizationStatusExpectation: XCTestExpectation
    private let deliveredExpectation: XCTestExpectation
    private let addExpectation: XCTestExpectation

    init(removeExpectation: XCTestExpectation,
         authorizationStatusExpectation: XCTestExpectation,
         addExpectation: XCTestExpectation,
         deliveredExpectation: XCTestExpectation,
         authorizationStatus: UNAuthorizationStatus = .authorized,
         hasDelivered: Bool = false) {
        self.removeExpectation = removeExpectation
        self.authorizationStatusExpectation = authorizationStatusExpectation
        self.addExpectation = addExpectation
        self.deliveredExpectation = deliveredExpectation
        _authorizationStatus = authorizationStatus
        _hasDelivered = hasDelivered
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removeExpectation.fulfill()
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        completionHandler?(nil)
        addExpectation.fulfill()
    }
}
