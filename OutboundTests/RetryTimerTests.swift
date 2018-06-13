//
//  RetryTimerTests.swift
//  OutboundTests
//
//  Created by Alan Egan on 28/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

import XCTest
import OHHTTPStubs

class RetryTimerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        OHHTTPStubs.removeAllStubs()
        let configExpectation = XCTestExpectation(description: "Should return mock data from stub")
        stub(condition: configEndpoint(), response: body(with: TestDefaults.configBodyString, expectation: configExpectation))
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        self.wait(for: [configExpectation], timeout: 1)
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testRetryTimer() {
        
        let expectation = self.expectation(description: "Event request should have expected content")
        expectation.expectedFulfillmentCount = 4
        
        OBCallsCache.setMaxRetryAttempts(3)
        
        stub(condition: body(contains: "\"event\":\"event-one\"") && headers(), response: response(status: 500, fulfill: expectation))
        
        Outbound.trackEvent("event-one", withProperties: nil)
        
        self.wait(for: [expectation], timeout: 9)
        
    }
}
