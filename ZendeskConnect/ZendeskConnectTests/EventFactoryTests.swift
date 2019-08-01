/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import XCTest
import ZendeskConnect

class EventFactoryTests: XCTestCase {
    
    struct Data {
        var event : String
        var properties : [String : Any]?
    }
    
    var event : Event!
    var tests : [Data] = []
    
    var firstTest : Data!
    var secondTest : Data!
    var thirdTest : Data!
    var fourthTest : Data!
    var fifthTest : Data!
    
    override func setUp() {
        firstTest = Data(event : "firstEvent", properties : ["foo1": "bar1"])
        secondTest = Data(event : "secondEvent", properties : ["foo2": "bar2"])
        thirdTest = Data(event : "thirdEvent", properties : ["foo3": "bar3"])
        fourthTest = Data(event : "fourthEvent", properties : ["foo4": "bar4"])
        fifthTest = Data(event : "fifthEvent", properties : ["foo5": "bar5"])
        //Data provider
        tests = [firstTest, secondTest, thirdTest, fourthTest, fifthTest]
    }

    override func tearDown() {
        event =  nil
        tests.removeAll()
    }
    
    /**
     General test that verifies the information is returned by `createEvent` function in `EventFactory` class.
    */
    func testElements() {
        //Get the first test
        let data = tests[0]
        event = EventFactory.createEvent( event: data.event, properties: data.properties)
        let timestamp: TimeInterval = Date().timeIntervalSince1970
    
        XCTAssertEqual(event.userId, nil)
        XCTAssertEqual(event.event, data.event, "Verify that the correct event is returned")
        XCTAssertEqual(event.properties?.keys, data.properties?.keys, "Verify that the correct properties are returned")
        XCTAssertEqual(event.properties?.values.description, data.properties?.values.description, "Verify that the correct properties are returned")
    
        let timeElapsed =  timestamp - event.timestamp
        print("timestamp " + timestamp.description + " event.timestamp " + event.timestamp.description + "  timeElapsed " + timeElapsed.description )
        XCTAssertLessThan(timeElapsed, 0.5, "Verify if timestamp is according with actual time")
    }
    
    /**
     Test that the properties field has the correct structure and values.
    */
    func testIntegrityOfProperties() {
        //Get the first test
        let data = tests[0]
        event = EventFactory.createEvent(event: data.event, properties: data.properties)
        XCTAssertEqual(event.properties?.keys, data.properties?.keys, "Verify that the correct keys are returned")
        XCTAssertEqual(event.properties?.values.description, data.properties?.values.description, "Verify that the correct values are returned")
        XCTAssertEqual(event.properties?.description, data.properties?.description, "Verify that the correct properties are returned")
    }
 
    /**
     Test that returned information is correct when multiple events are created
     */
    func testCreateMultipleEvents() {
        
        for test in tests{
            let data : Data = test
            event = EventFactory.createEvent( event: data.event, properties: data.properties)
            let timestamp: TimeInterval = Date().timeIntervalSince1970
            XCTAssertEqual(event.event, data.event, "Verify that the correct event is returned")
            XCTAssertEqual(event.properties?.keys, data.properties?.keys, "Verify that the correct properties are returned")
            XCTAssertEqual(event.properties?.description, data.properties?.description, "Verify that the correct properties are returned")
            let timeElapsed =  timestamp - event.timestamp
            print(timeElapsed)
            XCTAssertLessThan(timeElapsed, 0.5, "Verify if timestamp is according with actual time")
        }
    }
    /**
     Test when an event is created without properties
    */
    func testNoProperties() {
        //Get the first test
        let data : Data = tests[0]
        event = EventFactory.createEvent( event: data.event)
        XCTAssertEqual(event.event, data.event, "Verify that the correct event is returned")
        XCTAssertNil(event.properties, "Verify that properties are nil")
    }
    /**
     Test that an event is created, the default value for userId is `nil`
    */
    func testUserId() {
        //Get the first test
        let data : Data = tests[0]
        event = EventFactory.createEvent( event: data.event)
        XCTAssertNil(event.userId, "Verify that userId is nil by default")
    }
}
