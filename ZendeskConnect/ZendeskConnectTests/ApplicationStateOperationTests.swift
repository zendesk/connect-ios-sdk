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

final class ApplicationStateOperationTests: XCTestCase {

    struct MockApplication: Application {
        var mockState: UIApplication.State
        var applicationState: UIApplication.State {
            return mockState
        }
    }

    var operationQueue: OperationQueue!

    override func setUp() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    }

    func testIsAsynchronous() {
        let operation = ApplicationStateOperation(application: MockApplication(mockState: .background))
        XCTAssertTrue(operation.isAsynchronous)
    }

    func testFinishesOnNotification() {

        let operation = ApplicationStateOperation(application: MockApplication(mockState: .background))

        let expectation = self.expectation(description: "Should complete after did become active")
        let assertionOperation = ExpectationOperation(expectation: expectation)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        operationQueue.addOperations([operation, assertionOperation], waitUntilFinished: false)

        wait(for: [expectation], timeout: 2)
    }

    func testWaitsForNotification() {

        let operation = ApplicationStateOperation(application: MockApplication(mockState: .background))

        let expectation = self.expectation(description: "Should timeout, still waiting for notification")
        expectation.isInverted = true

        operationQueue.addOperations([operation], waitUntilFinished: false)

        wait(for: [expectation], timeout: 1)
    }

    func testCompletesImmediatelyInActiveState() {

        let operation = ApplicationStateOperation(application: MockApplication(mockState: .active))

        let expectation = self.expectation(description: "Should complete immediately without posted notification")
        let assertionOperation = ExpectationOperation(expectation: expectation)

        operationQueue.addOperations([operation, assertionOperation], waitUntilFinished: false)

        wait(for: [expectation], timeout: 1)
    }
}
