//
//  TrackEventTests.swift
//  OutboundTests
//
//  Created by Alan Egan on 22/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

import XCTest
import OHHTTPStubs

class TrackEventTests: XCTestCase {
    
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
    
    func testEventWithNillProperties() {
        
        let expectation = self.expectation(description: "Event request should have expected content")
        
        stub(condition: body(contains: "\"event\":\"event-one\"") && headers(),
             response: OK(fulfill: expectation))
        
        Outbound.trackEvent("event-one", withProperties: [:])
        
        self.wait(for: [expectation], timeout: 2)
    }
    
    func testEventWithProperties() {
        
        let expectation = self.expectation(description: "Event request should have expected content")
        
        stub(condition:
            body(contains: "\"event\":\"event-one\"") &&
                body(contains: "\"properties\":{\"property-one\":\"value-one\"}") &&
                headers(),
             response: OK(fulfill: expectation))
        
        Outbound.trackEvent("event-one", withProperties: ["property-one":"value-one"])
        
        self.wait(for: [expectation], timeout: 2)
    }
    
    func testEventWithPropertiesContainingDifferentTypes() {
        
        let expectation = self.expectation(description: "Event request should have expected content")
        
        stub(condition:
            body(contains: "\"event\":\"event-one\"") &&
                body(contains: "\"properties\":{") &&
                body(contains: "\"property-one\":\"value-one\"") &&
                body(contains: "\"property-two\":2") &&
                body(contains: "\"property-three\":true") &&
                headers(),
             response: OK(fulfill: expectation))
        
        Outbound.trackEvent("event-one", withProperties: ["property-one":"value-one", "property-two": 2, "property-three": true])
        
        self.wait(for: [expectation], timeout: 2)
    }
    
    func testDeDupEvent() {
        
        let expectation = self.expectation(description: "Repeated event request should have different guids.")
        expectation.expectedFulfillmentCount = 2
        var guid: String?
        
        stub(condition: body(contains: "\"event\":\"event-one\"")) { request -> OHHTTPStubsResponse in
            
            if let guid = guid,
                let dedup = request.allHTTPHeaderFields?["X-Outbound-GUID"] {
                XCTAssertFalse(dedup == guid)
            }
            guid = request.allHTTPHeaderFields?["X-Outbound-GUID"]
            expectation.fulfill()
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        Outbound.trackEvent("event-one", withProperties: nil)
        Outbound.trackEvent("event-one", withProperties: nil)
        
        self.wait(for: [expectation], timeout: 2)
    }
    
}
