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

final class StoreIPMOperationTests: XCTestCase {

    private var operationQueue: OperationQueue!

    override func setUp() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    }

    private func getStandardIPM() -> IPM {
        let ipmDictionary: [AnyHashable: Any] = [
            IPMKeys.oid: "1234",
            IPMKeys.logo: "https://image.com/image.jpg",
            IPMKeys.heading: "I'm an IPM",
            IPMKeys.message: "I have a message",
            IPMKeys.messageFontColor: "#000000",
            IPMKeys.headingFontColor: "#000000",
            IPMKeys.backgroundColor: "#FFFFFF",
            IPMKeys.buttonText: "Pie!",
            IPMKeys.buttonBackgroundColor: "#787879",
            IPMKeys.buttonTextColor: "#FFFFFF",
            IPMKeys.action: "guide://subdomain/articles?articleId=pie",
            IPMKeys.ttl: "100"
        ]

        let ipm = decode(dictionary: ipmDictionary, to: IPM.self)!
        return ipm
    }

    func testSavingIPMToStorageWhenAnIPMAlreadyExists() {
        
        let removeExpectation  = expectation(description: "removePendingNotificationRequests should be called.")
        let storeExpectation = expectation(description: "An IPM should be stored.")
        let clearStorageExpectation = expectation(description: "Clear shouldn't be called.")
        clearStorageExpectation.isInverted = true
        let deliveredExpectation = expectation(description: "hasDelivered shouldn't be called")
        deliveredExpectation.isInverted = true
        let authorizationStatusExpectation = expectation(description: "authorizationStatus shouldn't be called")
        authorizationStatusExpectation.isInverted = true
        let addExpectation = expectation(description: "add (UNNotificationRequest) shouldn't be called")
        addExpectation.isInverted = true

        let storage = MockStorage(clearedExpectation: clearStorageExpectation,
                                  writeIPMExpectation: storeExpectation,
                                  storedIPM: nil,
                                  storedIdentifier: "1234")

        let mockCenter = MockUserNotificationCenterWrapper(removeExpectation: removeExpectation,
                                                             authorizationStatusExpectation: authorizationStatusExpectation,
                                                             addExpectation: addExpectation,
                                                             deliveredExpectation: deliveredExpectation)

        let operation = StoreIPMOperation(ipm: getStandardIPM(), storage: storage, center: mockCenter)
        operationQueue.addOperation(operation)

        let expectations = [removeExpectation,
                            storeExpectation,
                            clearStorageExpectation,
                            deliveredExpectation,
                            authorizationStatusExpectation,
                            addExpectation]

        wait(for: expectations, timeout: 1)
    }
}
