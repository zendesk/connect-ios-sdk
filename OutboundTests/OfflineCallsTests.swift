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
@testable import ZendeskConnect

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
        
        OBMainController.sharedInstance().connect.eventQueue.objectQueue.clear()
        OBMainController.sharedInstance().connect.identifyQueue.objectQueue.clear()
        
        ZendeskConnect.Reachability.testing = true
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
        OBMainController.sharedInstance().connect.eventQueue.objectQueue.clear()
        OBMainController.sharedInstance().connect.identifyQueue.objectQueue.clear()
        ZendeskConnect.Reachability.testing = false
        
    }
    
    func testOfflineCallsAreCached() {
        TestHelpersObjC.mockNetworkStatus(OBNotReachable)
        
        let connect: Connect = OBMainController.sharedInstance().connect
        
        XCTAssertEqual(connect.eventQueue.size, 0)
        
        Outbound.trackEvent("offline-one", withProperties: nil)
        Outbound.trackEvent("offline-two", withProperties: nil)
        
        XCTAssertEqual(connect.eventQueue.size, 2)
    }
    
    func testOfflineIdentify() {
        TestHelpersObjC.mockNetworkStatus(OBNotReachable)
        
        let connect: Connect = OBMainController.sharedInstance().connect
        
        XCTAssertEqual(connect.eventQueue.size, 0)
        
        Outbound.trackEvent("offline-one", withProperties: nil)
        
        XCTAssertEqual(connect.eventQueue.size, 1)
   
        Outbound.identifyUser(withId: "1234", attributes: nil)
        
        let calls = connect.identifyQueue.objectQueue.asArray()
        
        XCTAssertEqual(calls.count, 1)
        
        XCTAssertEqual(calls.first?.userId, "1234")
    }

}
