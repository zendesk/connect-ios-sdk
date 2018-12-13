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

class UserStorageTests: XCTestCase {
    
    let user = User(firstName: "first name",
                    lastName: "last name",
                    email: "email",
                    attributes: [:],
                    userId: "user id",
                    previousId: "previous id",
                    phoneNumber: "123465848",
                    groupId: "group id",
                    groupAttributes: [:],
                    timezone: "c 137",
                    gcm: ["fake-push-notification-token"],
                    apns: ["fake-push-notification-token"])
    
    var userStorage: UserStorage!
    
    override func setUp() {
        super.setUp()
        userStorage = UserStorage()
        userStorage.clear()
    }
    
    override func tearDown() {
        super.tearDown()
        userStorage.clear()
    }
    
    func testUserStorageAndRetrieval() {
        userStorage.store(user)

        let storedUser = userStorage.readUser()

        XCTAssertNotNil(storedUser)
        XCTAssertEqual(storedUser?.firstName, user.firstName)
        XCTAssertEqual(storedUser?.lastName, user.lastName)
        XCTAssertEqual(storedUser?.email, user.email)
        XCTAssertEqual(storedUser?.userId, user.userId)
        XCTAssertEqual(storedUser?.previousId, user.previousId)
        XCTAssertEqual(storedUser?.phoneNumber, user.phoneNumber)
        XCTAssertEqual(storedUser?.groupId, user.groupId)
        XCTAssertEqual(storedUser?.timezone, user.timezone)
        XCTAssertEqual(storedUser?.gcm, user.gcm)
        XCTAssertEqual(storedUser?.apns, user.apns)
        
        userStorage.store(User(userId: "Not the same user"))
        
        let notTheSameUser = userStorage.readUser()
        XCTAssertNotNil(notTheSameUser)
        XCTAssertNotEqual(notTheSameUser?.userId, user.userId)
    }

    func testTokenStorageAndRetrieval() {
        let token = "fake-push-notification-token".data(using: .utf8)!
        userStorage.store(token)

        let storedToken = userStorage.readToken()

        XCTAssertNotNil(storedToken)
        XCTAssertEqual(storedToken, token)
        
        userStorage.store("some-other-token".data(using: .utf8)!)
       
        let differentStoredToken = userStorage.readToken()
        
        XCTAssertNotNil(differentStoredToken)
        XCTAssertNotEqual(differentStoredToken, token)
    }
    
    func testThingsShouldBeNil() {
        XCTAssertNil(userStorage.readToken())
        XCTAssertNil(userStorage.readUser())
    }
}


class ConfigStorageTests: XCTestCase {
    
    var configStorage: ConfigStorage!
    let config = Config(enabled: true, account: AccountConfig(prompt: true, promptEvent: "event", prePrompt: nil))
    
    override func setUp() {
        super.setUp()
        configStorage = ConfigStorage()
        configStorage.clear()
    }
    
    func testConfigNilWhenNothingIsStored() {
        XCTAssertNil(configStorage.readConfig())
    }

    
    func testConfigStorageAndRetrieval() {
        configStorage.store(config: config)
        
        let storedConfig = configStorage.readConfig()
        
        XCTAssertNotNil(storedConfig)
        
        XCTAssertEqual(storedConfig?.enabled, config.enabled)
        XCTAssertEqual(storedConfig?.account?.prompt, config.account?.prompt)
        XCTAssertEqual(storedConfig?.account?.promptEvent, config.account?.promptEvent)
    }
}
