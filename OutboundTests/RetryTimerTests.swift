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
        
        
        OBMainController.sharedInstance().callsCache.addCall("/no/where", withParameters: ["event":"event-one"])
        self.wait(for: [expectation], timeout: 9)
        
    }
}
