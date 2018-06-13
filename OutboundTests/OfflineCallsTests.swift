//
//  OfflineCallsTests.swift
//  OutboundTests
//
//  Created by Alan Egan on 28/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

import XCTest
import OHHTTPStubs

class OfflineCallsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        OHHTTPStubs.removeAllStubs()
        let configExpectation = XCTestExpectation(description: "Should return mock data from stub")
        stub(condition: configEndpoint(), response: body(with: TestDefaults.noPromptConfigBodyString, expectation: configExpectation))
        Outbound.initWithPrivateKey(TestDefaults.apiKey)
        self.wait(for: [configExpectation], timeout: 1)
        
        OBMainController.sharedInstance().callsCache.userId = nil
        OBMainController.sharedInstance().callsCache.tempUserId = nil
        OBMainController.sharedInstance().callsCache.calls.removeAllObjects()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testOfflineCallsAreCached() {
        TestHelpersObjC.mockNetworkStatus(OBNotReachable)
        
        XCTAssertEqual(OBMainController.sharedInstance().callsCache.calls.count, 0)
        
        Outbound.trackEvent("offline-one", withProperties: nil)
        Outbound.trackEvent("offline-two", withProperties: nil)
        
        XCTAssertEqual(OBMainController.sharedInstance().callsCache.calls.count, 2)
    }
    
    func testOfflineIdentify() {
        TestHelpersObjC.mockNetworkStatus(OBNotReachable)
        
        XCTAssertEqual(OBMainController.sharedInstance().callsCache.calls.count, 0)
        
        Outbound.trackEvent("offline-one", withProperties: nil)
        
        XCTAssertEqual(OBMainController.sharedInstance().callsCache.calls.count, 1)
        
        guard let calls = OBMainController.sharedInstance().callsCache.calls as? [OBCall] else {
            XCTFail("Cache should contain OBCalls.")
            return
        }
        
        XCTAssertEqual(calls.first?.path, "v2/track")
        XCTAssertNotNil(calls.first?.tempUserId)
        XCTAssertNil(calls.first?.userId)
        
        Outbound.identifyUser(withId: "1234", attributes: nil)
        
        XCTAssertEqual(calls.first?.userId, "1234")
        XCTAssertEqual(OBMainController.sharedInstance().callsCache.calls.count, 3)
        
        guard
            let aliasCall = OBMainController.sharedInstance().callsCache.calls[1] as? OBCall,
            let timezoneCall = OBMainController.sharedInstance().callsCache.calls[2] as? OBCall
            else { return }
        
        XCTAssertEqual(aliasCall.path, "v2/identify")
        XCTAssertEqual(timezoneCall.path, "v2/identify")
        
        XCTAssertNotNil(aliasCall.tempUserId)
        XCTAssertNil(aliasCall.userId)
        
        XCTAssertNil(timezoneCall.tempUserId)
        XCTAssertEqual(timezoneCall.userId, "1234")
    }

}
