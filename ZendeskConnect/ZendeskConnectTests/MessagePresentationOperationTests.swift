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

final class MessagePresentationOperationTests: XCTestCase {

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

    func testShouldPresentWhenLocalNotificationIsNotDelivered() {
        let resource = ImageResource(remoteURL: nil)
        let clearStorageExpectation = expectation(description: "Clear should always be called.")
        let writeStorageExpectation = expectation(description: "Write should never be called.")
        writeStorageExpectation.isInverted = true
        let startExpectation = expectation(description: "Start should be called")
        let removeExpectation  = expectation(description: "removePendingNotificationRequests should be called")
        let deliveredExpectation = expectation(description: "hasDelivered should be called")
        let authorizationStatusExpectation = expectation(description: "authorizationStatus shouldn't be called")
        authorizationStatusExpectation.isInverted = true
        let addExpectation = expectation(description: "add (UNNotificationRequest) shouldn't be called")
        addExpectation.isInverted = true

        

        let storage = MockStorage(clearedExpectation: clearStorageExpectation,
                                  writeIPMExpectation: writeStorageExpectation,
                                  storedIPM: getStandardIPM(),
                                  storedIdentifier: "1234")

        let mockCenter = MockUserNotificationCenterWrapper(removeExpectation: removeExpectation,
                                                           authorizationStatusExpectation: authorizationStatusExpectation,
                                                           addExpectation: addExpectation,
                                                           deliveredExpectation: deliveredExpectation)

        let messageOperation = MessagePresentationOperation(imageResource: resource,
                                                            coordinator: MockCoordinator(expectation: startExpectation),
                                                            storage: storage,
                                                            center: mockCenter)

        operationQueue.addOperations([messageOperation], waitUntilFinished: false)

        let expectations =  [clearStorageExpectation,
                             writeStorageExpectation,
                             startExpectation,
                             removeExpectation,
                             deliveredExpectation,
                             authorizationStatusExpectation,
                             addExpectation]

        wait(for: expectations, timeout: 1)
    }

    func testWontPresentWhenNothingInStorage() {
        let resource = ImageResource(remoteURL: nil)
        let clearStorageExpectation = expectation(description: "Clear should always be called.")
        let writeStorageExpectation = expectation(description: "Write should never be called.")
        writeStorageExpectation.isInverted = true
        let startExpectation = expectation(description: "Start shouldn't get called.")
        startExpectation.isInverted = true
        let removeExpectation  = expectation(description: "removePendingNotificationRequests should't get called")
        removeExpectation.isInverted = true
        let deliveredExpectation = expectation(description: "hasDelivered shouldn't be called")
        deliveredExpectation.isInverted = true 
        let authorizationStatusExpectation = expectation(description: "authorizationStatus shouldn't be called")
        authorizationStatusExpectation.isInverted = true
        let addExpectation = expectation(description: "add (UNNotificationRequest) shouldn't be called")
        addExpectation.isInverted = true

        let storage = MockStorage(clearedExpectation: clearStorageExpectation,
                                  writeIPMExpectation: writeStorageExpectation,
                                  storedIPM: nil,
                                  storedIdentifier: "1")

        let mockCenter = MockUserNotificationCenterWrapper(removeExpectation: removeExpectation,
                                                           authorizationStatusExpectation: authorizationStatusExpectation,
                                                           addExpectation: addExpectation,
                                                           deliveredExpectation: deliveredExpectation)

        let messageOperation = MessagePresentationOperation(imageResource: resource,
                                                            coordinator: MockCoordinator(expectation: startExpectation),
                                                            storage: storage,
                                                            center: mockCenter)

        operationQueue.addOperations([messageOperation], waitUntilFinished: false)

        let expectations =  [clearStorageExpectation,
                             writeStorageExpectation,
                             startExpectation,
                             removeExpectation,
                             deliveredExpectation,
                             authorizationStatusExpectation,
                             addExpectation]

        wait(for: expectations, timeout: 1)
    }

    func testWontPresentWhenLocalNotificationHasBeenDelivered() {
        let resource = ImageResource(remoteURL: nil)
        let clearStorageExpectation = expectation(description: "Clear should always be called.")
        let writeStorageExpectation = expectation(description: "Write should never be called.")
        writeStorageExpectation.isInverted = true
        let deliveredExpectation = expectation(description: "hasDelivered should be called")
        let startExpectation = expectation(description: "Start shouldn't be called.")
        startExpectation.isInverted = true
        let removeExpectation  = expectation(description: "removePendingNotificationRequests should not be called")
        removeExpectation.isInverted = true
        let authorizationStatusExpectation = expectation(description: "authorizationStatus should not be called")
        authorizationStatusExpectation.isInverted = true
        let addExpectation = expectation(description: "add (UNNotificationRequest) should be called")
        addExpectation.isInverted = true

        let storage = MockStorage(clearedExpectation: clearStorageExpectation,
                                  writeIPMExpectation: writeStorageExpectation,
                                  storedIPM: getStandardIPM(),
                                  storedIdentifier: "1")

        let mockCenter = MockUserNotificationCenterWrapper(removeExpectation: removeExpectation,
                                                           authorizationStatusExpectation: authorizationStatusExpectation,
                                                           addExpectation: addExpectation,
                                                           deliveredExpectation: deliveredExpectation,
                                                           hasDelivered: true)

        let messageOperation = MessagePresentationOperation(imageResource: resource,
                                                            coordinator: MockCoordinator(expectation: startExpectation),
                                                            storage: storage,
                                                            center: mockCenter)

        operationQueue.addOperations([messageOperation], waitUntilFinished: false)

        let expectations =  [clearStorageExpectation,
                             writeStorageExpectation,
                             startExpectation,
                             removeExpectation,
                             deliveredExpectation,
                             authorizationStatusExpectation,
                             addExpectation]

        wait(for: expectations, timeout: 1)

    }
}
