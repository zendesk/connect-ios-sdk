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

class ZCNEventTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        OHHTTPStubs.removeAllStubs()
    }
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testEventWithNillProperties() {
        
        let expectation = self.expectation(description: "Event request should have expected content")
        
        stub(condition: body(contains: "\"event\":\"event-one\"") && headers(),
             response: OK(fulfill: expectation))

        let client = Client(host: URL(string: "https://example.com")!,
                            requestDecorator: [OutboundClientDecorator(with: "\(PlatformString)/\(ConnectVersionString)"),
                                               OutboundKeyDecorator(with: TestDefaults.apiKey),
                                               ConnectGUIDDecorator()])

        let eventProvider = EventProvider(with: client)
        eventProvider.track(body: Event(userId: "1234", properties: nil, event: "event-one"), completion: { _ in} )
        
        self.wait(for: [expectation], timeout: 2)
    }
    
    func testEventWithProperties() {

        let expectation = self.expectation(description: "Event request should have expected content")

        stub(condition:
            body(contains: "\"event\":\"event-one\"") &&
                body(contains: "\"properties\":{\"property-one\":\"value-one\"}") &&
                headers(),
             response: OK(fulfill: expectation))

        let client = Client(host: URL(string: "https://example.com")!,
                            requestDecorator: [OutboundClientDecorator(with: "\(PlatformString)/\(ConnectVersionString)"),
                                               OutboundKeyDecorator(with: TestDefaults.apiKey),
                                               ConnectGUIDDecorator()])

        let eventProvider = EventProvider(with: client)
        eventProvider.track(body: Event(userId: "1234", properties: ["property-one":"value-one"], event: "event-one"), completion: { _ in} )

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

        let client = Client(host: URL(string: "https://example.com")!,
                            requestDecorator: [OutboundClientDecorator(with: "\(PlatformString)/\(ConnectVersionString)"),
                                               OutboundKeyDecorator(with: TestDefaults.apiKey),
                                               ConnectGUIDDecorator()])

        let eventProvider = EventProvider(with: client)
        eventProvider.track(body: Event(userId: "1234", properties: ["property-one":"value-one", "property-two": 2, "property-three": true], event: "event-one"), completion: { _ in} )

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

        let client = Client(host: URL(string: "https://example.com")!,
                            requestDecorator: [OutboundClientDecorator(with: "\(PlatformString)/\(ConnectVersionString)"),
                                               OutboundKeyDecorator(with: TestDefaults.apiKey),
                                               ConnectGUIDDecorator()])

        let eventProvider = EventProvider(with: client)
        eventProvider.track(body: Event(userId: "1234", properties: nil, event: "event-one"), completion: { _ in} )
        eventProvider.track(body: Event(userId: "1234", properties: nil, event: "event-one"), completion: { _ in} )

        self.wait(for: [expectation], timeout: 2)
    }

}
