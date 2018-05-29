//
//  ExecuteAfterConfigTests.swift
//  OutboundTests
//
//  Created by Alan Egan on 28/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

import XCTest
import OHHTTPStubs

class ExecuteAfterConfigTests: XCTestCase {
    
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
    
    func testExecuteAfterConfigCorrectOrder() {
        XCTAssertNil(OBConfig.configFilePath(), "Config path should be nil for this test.")
        
        let configExpectation = XCTestExpectation(description: "Should fulfill config expectation first.")
        
        stub(condition: configEndpoint(), response: body(with: TestDefaults.configBodyString, expectation: configExpectation))
        
        let trackExpectation = XCTestExpectation(description: "Should fulfill track expectation last.")
        trackExpectation.expectedFulfillmentCount = 2
        
        stub(condition: body(contains: "\"event\":\"pre-config-event\"") && headers(),
             response: OK(fulfill: trackExpectation))
        
        Outbound.trackEvent("pre-config-event", withProperties: nil)
        Outbound.trackEvent("pre-config-event", withProperties: nil)
        
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        
        self.wait(for: [configExpectation, trackExpectation], timeout: 10, enforceOrder: true)
    }
    
}
