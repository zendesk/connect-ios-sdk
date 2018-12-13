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

struct TestUserStorage: UserStorable {

    init() {}

    static var user: User?
    static var token: Data?

    func store(_ user: User) {
        TestUserStorage.user = user
    }

    func store(_ token: Data) {
        TestUserStorage.token = token
    }

    func clear() {
        TestUserStorage.user = nil
        TestUserStorage.token = nil
    }

    func readUser() -> User? {
        return TestUserStorage.user
    }

    func readToken() -> Data? {
        return TestUserStorage.token
    }
}

struct TestConfigStorage: ConfigStorable {

    static var config: Config?

    init() {}

    func store(config: Config) {
        TestConfigStorage.config = config
    }

    func clear() {
        TestConfigStorage.config = nil
    }

    func readConfig() -> Config? {
        return TestConfigStorage.config
    }
}

class TestEnvironmentStorage: EnvironmentStorable {

    static var testKey: String?

    var privateKey: String? {
        get {
            return TestEnvironmentStorage.testKey
        }
        set {
            TestEnvironmentStorage.testKey = newValue
        }
    }

    required init() {}
}

class ConnectShadowFactoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        nilOutTestTypes()
    }

    override func tearDown() {
        super.tearDown()
        nilOutTestTypes()
    }

    func nilOutTestTypes() {
        TestEnvironmentStorage.testKey = nil
        TestUserStorage.user = nil
        TestUserStorage.token = nil
        TestConfigStorage.config = nil
    }
    
    func testColdStartWithNothingStoredInAnyStorage() {

        
        let connect = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                               userStorageType: TestUserStorage.self,
                                                               configStorageType: TestConfigStorage.self,
                                                               environmentStorableType: TestEnvironmentStorage.self,
                                                               currentInstance: nil)

        XCTAssertNotNil(connect)
        XCTAssertEqual("testing", connect?.privateKey)
    }

    func testWarmStartWithSameKey() {

        let first = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                             userStorageType: TestUserStorage.self,
                                                             configStorageType: TestConfigStorage.self,
                                                             environmentStorableType: TestEnvironmentStorage.self,
                                                             currentInstance: nil)
        XCTAssertNotNil(first)

        let second = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                              userStorageType: TestUserStorage.self,
                                                              configStorageType: TestConfigStorage.self,
                                                              environmentStorableType: TestEnvironmentStorage.self,
                                                              currentInstance: first)
        XCTAssertNotNil(second)
        XCTAssertEqual(first, second)
    }

    func testWarmStartWithDifferentKey() {

        let first = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                             userStorageType: TestUserStorage.self,
                                                             configStorageType: TestConfigStorage.self,
                                                             environmentStorableType: TestEnvironmentStorage.self,
                                                             currentInstance: nil)
        XCTAssertNotNil(first)

        let second = ConnectShadowFactory.createConnectShadow(privateKey: "different-key",
                                                             userStorageType: TestUserStorage.self,
                                                             configStorageType: TestConfigStorage.self,
                                                             environmentStorableType: TestEnvironmentStorage.self,
                                                             currentInstance: first) // pass the second instance in

        XCTAssertNotEqual(first, second)
        XCTAssertEqual(second?.privateKey, "different-key")
    }

    func testStartWithUserStoredSameKey() {

        TestEnvironmentStorage.testKey = "testing"
        let testUser = User(userId: "1234")
        TestUserStorage.user = testUser

        let connectShadow = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                               userStorageType: TestUserStorage.self,
                                                               configStorageType: TestConfigStorage.self,
                                                               environmentStorableType: TestEnvironmentStorage.self,
                                                               currentInstance: nil)

        XCTAssertNotNil(connectShadow)
        XCTAssertEqual(connectShadow?.privateKey, "testing")
        // User should be the same
        XCTAssertEqual(testUser.userId, connectShadow?.user.userId)
    }

    func testStartWithUserStoredDifferentKey() {

        TestEnvironmentStorage.testKey = "different-key"
        let testUser = User(userId: "1234")
        TestUserStorage.user = testUser

        let connectShadow = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                               userStorageType: TestUserStorage.self,
                                                               configStorageType: TestConfigStorage.self,
                                                               environmentStorableType: TestEnvironmentStorage.self,
                                                               currentInstance: nil)

        XCTAssertNotNil(connectShadow)
        XCTAssertEqual("testing", connectShadow?.privateKey)
        // User should be cleared and have a temp ID
        XCTAssertNotEqual(testUser.userId, connectShadow?.user.userId)
    }

    func testStartConfigStoredSameKey() {

        TestConfigStorage.config = Config.init(enabled: false, account: AccountConfig(prompt: false, promptEvent: "test", prePrompt: nil))

        let connectShadow = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                               userStorageType: TestUserStorage.self,
                                                               configStorageType: TestConfigStorage.self,
                                                               environmentStorableType: TestEnvironmentStorage.self,
                                                               currentInstance: nil)

        XCTAssertNotNil(connectShadow)
        // Should be the same as the test config
        XCTAssertFalse((connectShadow?.configuration.enabled)!)
        XCTAssertNotNil(connectShadow?.configuration.account)
    }

    func testStartConfigStoredDifferentKey() {
        TestEnvironmentStorage.testKey = "different-key"
        TestConfigStorage.config = Config.init(enabled: false, account: nil)

        let connectShadow = ConnectShadowFactory.createConnectShadow(privateKey: "testing",
                                                               userStorageType: TestUserStorage.self,
                                                               configStorageType: TestConfigStorage.self,
                                                               environmentStorableType: TestEnvironmentStorage.self,
                                                               currentInstance: nil)

        XCTAssertNotNil(connectShadow)
        // config should be wiped and default values provided
        XCTAssertTrue((connectShadow?.configuration.enabled)!)
        XCTAssertNil(connectShadow?.configuration.account)
    }

}
