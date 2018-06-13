//
//  ConfigTests.swift
//  OutboundTests
//
//  Created by Alan Egan on 23/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

import XCTest
import OHHTTPStubs

class ConfigTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        OHHTTPStubs.removeAllStubs()
        // must be nil to test cold start.
        OBMainController.sharedInstance()?.config = nil
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testInitConfigFetching() {
        
        XCTAssertNil(OBConfig.configFilePath(), "Config path should be nil for this test.")
        
        let expectation = XCTestExpectation(description: "Should return mock data from stub")
        
        let bodyString = """
                        {
                            "account" : {
                                "prompt" : true
                            },
                            "enabled" : true,
                        }
                        """
        
        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))
        
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        
        self.wait(for: [expectation], timeout: 1)
        
        guard let config = OBMainController.sharedInstance().config else {
            XCTFail("Config was nil")
            return
        }
        
        XCTAssertTrue(config.promptForPermission)
        XCTAssertFalse(config.remoteKill)
        XCTAssertTrue(config.promptAtInstall)
    }
    
    func testInitConfigFetchingRemoteKill() {
        
        XCTAssertNil(OBConfig.configFilePath(), "Config path should be nil for this test.")
        
        let expectation = XCTestExpectation(description: "Should return mock data from stub")
        
        let bodyString = """
                        {
                            "enabled" : false
                        }
                        """
        
        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))
        
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        
        self.wait(for: [expectation], timeout: 1)
        
        guard let config = OBMainController.sharedInstance().config else {
            XCTFail("Config was nil")
            return
        }
        
        XCTAssertTrue(config.remoteKill)
    }
    
    func testInitConfigFetchingNoPrompt() {
        
        XCTAssertNil(OBConfig.configFilePath(), "Config path should be nil for this test.")
        
        let expectation = XCTestExpectation(description: "Should return mock data from stub")
        
        let bodyString = """
                        {
                            "account" : {
                                "prompt" : false
                            }
                        }
                        """
        
        stub(condition: configEndpoint(), response: body(with: bodyString, expectation: expectation))
        
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        
        self.wait(for: [expectation], timeout: 1)
        
        guard let config = OBMainController.sharedInstance().config else {
            XCTFail("Config was nil")
            return
        }
        
        XCTAssertFalse(config.promptForPermission)
    }
    
    func testInitConfigFetchingPromptEvent() {
        
        XCTAssertNil(OBConfig.configFilePath(), "Config path should be nil for this test.")
        
        let expectation = XCTestExpectation(description: "Should return mock data from stub")
        
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
        
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        
        self.wait(for: [expectation], timeout: 1)
        
        guard let config = OBMainController.sharedInstance().config else {
            XCTFail("Config was nil")
            return
        }
        
        XCTAssertTrue(config.promptForPermission)
        XCTAssertFalse(config.remoteKill)
        XCTAssertFalse(config.promptAtInstall)
        XCTAssertTrue(config.promptAtEvent == "event-one")
        XCTAssertNotNil(config.fetchDate)
    }
    
    func testInitConfigFetchingPrePrompt() {
        
        XCTAssertNil(OBConfig.configFilePath(), "Config path should be nil for this test.")
        
        let expectation = XCTestExpectation(description: "Should return mock data from stub")
        
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
        
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        
        self.wait(for: [expectation], timeout: 1)
        
        guard let config = OBMainController.sharedInstance().config else {
            XCTFail("Config was nil")
            return
        }
        
        XCTAssertTrue(config.promptForPermission)
        XCTAssertFalse(config.remoteKill)
        XCTAssertFalse(config.promptAtInstall)
        XCTAssertEqual(config.promptAtEvent, "event-one")
        XCTAssertNotNil(config.prePrompt)
        
        guard let prompt = config.prePrompt as? [String: String] else {
            XCTFail("Pre prompt should contain values.")
            return
        }
        XCTAssertEqual(prompt["title"], "Prompt Title")
        XCTAssertEqual(prompt["body"], "Prompt Body")
        XCTAssertEqual(prompt["no_button"], "Cancel")
        XCTAssertEqual(prompt["yes_button"], "OK")
    }
}
