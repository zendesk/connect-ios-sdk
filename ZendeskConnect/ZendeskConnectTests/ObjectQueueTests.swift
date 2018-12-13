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


/// This is because you can't have a fragments in JSON :(
/// https://bugs.swift.org/browse/SR-7213
/// https://bugs.swift.org/browse/SR-6163
struct T: Codable, Equatable {
    let value: String
}

class InMemoryObjectQueueTests: XCTestCase {
    
    var objectQueue: ObjectQueue<T>!

    override func setUp() {
        super.setUp()
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        objectQueue = ObjectQueue<T>.createInMemory()
        objectQueue.add(T(value: "one"))
        objectQueue.add(T(value: "two"))
        objectQueue.add(T(value: "three"))
        objectQueue.add(T(value: "four"))
        objectQueue.add(T(value: "five"))
        objectQueue.add(T(value: "six"))
        objectQueue.add(T(value: "seven"))
        objectQueue.add(T(value: "eight"))
        objectQueue.add(T(value: "nine"))
        objectQueue.add(T(value: "ten"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSize() {
        XCTAssertEqual(objectQueue.size, 10)
    }
    
    func testPeek() {
        XCTAssertEqual(objectQueue.peek()!, T(value: "one"))
    }
    
    func testPeekMultiple() {
        XCTAssertEqual(objectQueue.peek(2), [T(value: "one"),T(value: "two")])
    }
    
    func testPeekMaxCanExceedQueueDepth() {
        XCTAssertEqual(objectQueue.peek(13), [T(value: "one"),T(value: "two"),T(value: "three"),T(value: "four"),T(value: "five"),T(value: "six"),T(value: "seven"),T(value: "eight"),T(value: "nine"),T(value: "ten")])
    }
    
    func testRemove() {
        objectQueue.remove()
        XCTAssertEqual(objectQueue.asArray(), [T(value: "two"),T(value: "three"),T(value: "four"),T(value: "five"),T(value: "six"),T(value: "seven"),T(value: "eight"),T(value: "nine"),T(value: "ten")])
    }
    
    func testRemoveMultiple() {
        objectQueue.remove(3)
        XCTAssertEqual(objectQueue.asArray(), [T(value: "four"),T(value: "five"),T(value: "six"),T(value: "seven"),T(value: "eight"),T(value: "nine"),T(value: "ten")])
    }
    
    func testClear() {
        XCTAssertEqual(objectQueue.size, 10)
        objectQueue.clear()
        XCTAssertEqual(objectQueue.size, 0)
    }
    
    func testIsEmpty() {
        XCTAssertFalse(objectQueue.isEmpty)
        objectQueue.clear()
        XCTAssertTrue(objectQueue.isEmpty)
    }
}


class FileObjectQueueTests: XCTestCase {
    
    var objectQueue: ObjectQueue<T>!
    
    func newQueueFile() throws -> QueueFile {
        let fileUrl =  try FileUtility.url(name: "tests.dat")
        let fileHandle = try FileUtility.handle(url: fileUrl)
        fileHandle.truncateFile(atOffset: 0)
        let queue = QueueFile(fileHandle: fileHandle)
        return queue
    }
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            objectQueue = try ObjectQueue<T>.create(newQueueFile(), converter: DefaultConverter())
            objectQueue.add(T(value: "one"))
            objectQueue.add(T(value: "two"))
            objectQueue.add(T(value: "three"))
            objectQueue.add(T(value: "four"))
            objectQueue.add(T(value: "five"))
            objectQueue.add(T(value: "six"))
            objectQueue.add(T(value: "seven"))
            objectQueue.add(T(value: "eight"))
            objectQueue.add(T(value: "nine"))
            objectQueue.add(T(value: "ten"))
        } catch {
            XCTFail("Couldn't cerate queue file")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSize() {
        XCTAssertEqual(objectQueue.size, 10)
    }
    
    func testPeek() {
        XCTAssertEqual(objectQueue.peek()!, T(value: "one"))
    }
    
    func testPeekMultiple() {
        XCTAssertEqual(objectQueue.peek(2), [T(value: "one"),T(value: "two")])
    }
    
    func testPeekMaxCanExceedQueueDepth() {
        XCTAssertEqual(objectQueue.peek(13), [T(value: "one"),T(value: "two"),T(value: "three"),T(value: "four"),T(value: "five"),T(value: "six"),T(value: "seven"),T(value: "eight"),T(value: "nine"),T(value: "ten")])
    }
    
    func testRemove() {
        objectQueue.remove()
        XCTAssertEqual(objectQueue.asArray(), [T(value: "two"),T(value: "three"),T(value: "four"),T(value: "five"),T(value: "six"),T(value: "seven"),T(value: "eight"),T(value: "nine"),T(value: "ten")])
    }
    
    func testRemoveMultiple() {
        objectQueue.remove(3)
        XCTAssertEqual(objectQueue.asArray(), [T(value: "four"),T(value: "five"),T(value: "six"),T(value: "seven"),T(value: "eight"),T(value: "nine"),T(value: "ten")])
    }
    
    func testClear() {
        XCTAssertEqual(objectQueue.size, 10)
        objectQueue.clear()
        XCTAssertEqual(objectQueue.size, 0)
    }
    
    func testIsEmpty() {
        XCTAssertFalse(objectQueue.isEmpty)
        objectQueue.clear()
        XCTAssertTrue(objectQueue.isEmpty)
    }
}
