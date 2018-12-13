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
import OHHTTPStubs

class ConfigTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        OHHTTPStubs.removeAllStubs()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testInitConfigFetching() {

        let expectation = self.expectation(description: "Should return mock data from stub")
        
        let bodyString = """
                        {
                            "account" : {
                                "prompt" : true
                            },
                            "enabled" : true,
                        }
                        """
        
        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))

        let client = Client(host: URL(string: "https://example.com")!)
        let configProvider = ConfigProvider(with: client)
        configProvider.config(platform: PlatformString, version: ConnectVersionString) { result in

            XCTAssertTrue(result.isSuccess)

            guard
                let config = result.value,
                let account = config.account else {
                    XCTFail("Should have a config and account")
                    return
            }

            XCTAssertTrue(config.enabled)
            XCTAssertTrue(account.prompt!)
        }

        self.waitForExpectations(timeout: 1) { (error) in
            if error != nil {
                XCTFail("Failed to receive config and account")
            }
        }
    }
    
    func testInitConfigFetchingRemoteKill() {

        let expectation = self.expectation(description: "Should return mock data from stub")

        let bodyString = """
                        {
                            "enabled" : false
                        }
                        """

        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))

        let client = Client(host: URL(string: "https://example.com")!)
        let configProvider = ConfigProvider(with: client)
        configProvider.config(platform: PlatformString, version: ConnectVersionString) { result in

            XCTAssertTrue(result.isSuccess)

            guard let config = result.value else {
                XCTFail("Should have a config")
                return
            }

            XCTAssertFalse(config.enabled)
        }

        self.waitForExpectations(timeout: 1) { (error) in
            if error != nil {
                XCTFail("Failed to receive config")
            }
        }
    }

    func testInitConfigFetchingNoPrompt() {

        let expectation = self.expectation(description: "Should return mock data from stub")

        let bodyString = """
                        {
                            "account" : {
                                "prompt" : false
                            }
                        }
                        """

        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))

        let client = Client(host: URL(string: "https://example.com")!)
        let configProvider = ConfigProvider(with: client)
        configProvider.config(platform: PlatformString, version: ConnectVersionString) { result in

            XCTAssertTrue(result.isSuccess)

            guard
                let config = result.value,
                let account = config.account else {
                XCTFail("Should have a config and account")
                return
            }

            XCTAssertFalse(account.prompt!)
        }

        self.waitForExpectations(timeout: 1) { (error) in
            if error != nil {
                XCTFail("Failed to receive config and account")
            }
        }
    }

    func testInitConfigFetchingPromptEvent() {

        let expectation = self.expectation(description: "Should return mock data from stub")

        let bodyString = """
                        {
                            "account" : {
                                "prompt" : true,
                                "prompt_event" : "event-one"
                            },
                            "enabled" : true,
                        }
                        """

        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))

        let client = Client(host: URL(string: "https://example.com")!)
        let configProvider = ConfigProvider(with: client)
        configProvider.config(platform: PlatformString, version: ConnectVersionString) { result in

            XCTAssertTrue(result.isSuccess)

            guard
                let config = result.value,
                let account = config.account else {
                    XCTFail("Should have a config and account")
                    return
            }

            XCTAssertTrue(config.enabled)
            XCTAssertTrue(account.prompt!)
            XCTAssertEqual(account.promptEvent!, "event-one")

        }

        self.waitForExpectations(timeout: 1) { (error) in
            if error != nil {
                XCTFail("Failed to receive config and account")
            }
        }
    }

    func testInitConfigFetchingPrePrompt() {

        let expectation = self.expectation(description: "Should return mock data from stub")

        let bodyString = """
                        {
                            "account" : {
                                "prompt" : true,
                                "prompt_event" : "event-one",
                                "pre_prompt" : {
                                    "title": "Prompt Title",
                                    "body": "Prompt Body",
                                    "no_button": "Cancel",
                                    "yes_button": "OK"
                                }
                            },
                            "enabled" : true,
                        }
                        """

        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))

        let client = Client(host: URL(string: "https://example.com")!)
        let configProvider = ConfigProvider(with: client)
        configProvider.config(platform: PlatformString, version: ConnectVersionString) { result in

            XCTAssertTrue(result.isSuccess)

            guard
                let config = result.value,
                let account = config.account,
                let prePrompt = account.prePrompt else {
                    XCTFail("Should have a config, account and pre prompt")
                    return
            }

            XCTAssertTrue(config.enabled)
            XCTAssertTrue(account.prompt!)
            XCTAssertEqual(account.promptEvent!, "event-one")
            XCTAssertEqual(prePrompt.title, "Prompt Title")
            XCTAssertEqual(prePrompt.body, "Prompt Body")
            XCTAssertEqual(prePrompt.yesButton, "OK")
            XCTAssertEqual(prePrompt.noButton, "Cancel")

        }

        self.waitForExpectations(timeout: 1) { (error) in
            if error != nil {
                XCTFail("Should have a config, account and pre prompt")
            }
        }
    }
}
