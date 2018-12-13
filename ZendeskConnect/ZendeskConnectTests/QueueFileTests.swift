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

class QueueFileTests: XCTestCase {
    
    var testData = [
        "one".data(using: .utf8)!,
        "two".data(using: .utf8)!,
        "three".data(using: .utf8)!,
        "four".data(using: .utf8)!,
        "five".data(using: .utf8)!,
        "six".data(using: .utf8)!,
        "seven".data(using: .utf8)!,
        "eight".data(using: .utf8)!,
        "nine".data(using: .utf8)!,
        "ten".data(using: .utf8)!
    ]
    
    func newFileHandle() throws -> FileHandle {
        let fileUrl =  try FileUtility.url(name: "tests.dat")
        let fileHandle = try FileUtility.handle(url: fileUrl)
        return fileHandle
    }
    
    func newQueueFile(fileHandle: FileHandle? = nil) throws -> QueueFile {
        guard let fileHandle = fileHandle else {
            return QueueFile(fileHandle: try newFileHandle())
        }
        return QueueFile(fileHandle: fileHandle)
    }
    
    override func setUp() {
        super.setUp()
        
        do {
            let fileUrl =  try FileUtility.url(name: "tests.dat")
            let fileHandle = try FileUtility.handle(url: fileUrl)
            fileHandle.truncateFile(atOffset: 0)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddingAnElement() {
        
        do {
            var queue = try newQueueFile()
            let expected = testData[0]
            queue.add(expected)
            XCTAssertNotNil(queue.peek())
            XCTAssertEqual(expected, queue.peek()!)
            queue.close()
            queue = try newQueueFile()
            XCTAssertNotNil(queue.peek())
            XCTAssertEqual(expected, queue.peek()!)
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testClearTruncatesFile() {
        do {
            let fileUrl =  try FileUtility.url(name: "tests.dat")
            let fileHandle = try FileUtility.handle(url: fileUrl)
            let queue = QueueFile(fileHandle: fileHandle)
            let expected = testData[0]
            queue.add(expected)
            
            // Confirm that the data was in the file before we cleared.
            let firstOffset = FileHeader.headerLength + FileElement.headerLength
            
            do {
                fileHandle.seek(toFileOffset: firstOffset)
                let data = fileHandle.readData(ofLength: expected.count)
                XCTAssertEqual(expected, data)
            }
            
            queue.remove()
            
            do {
                fileHandle.seek(toFileOffset: firstOffset)
                let data = fileHandle.readData(ofLength: expected.count)
                // file should have been truncated
                XCTAssertEqual(data, Data.init(repeating: 0, count: 0))
            }
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testClearDoesNotCurrupt() {
        
        do {
            var queue = try newQueueFile()
            queue.add(testData[0])
            queue.clear()
            
            queue = try newQueueFile()
            XCTAssertTrue(queue.isEmpty)
            XCTAssertNil(queue.peek())
            
            let entry = testData[2]
            queue.add(entry)
            XCTAssertEqual(queue.peek()!, entry)
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testRemovingAnElementWithSizeOfTwo() {
        do {
            let fileUrl =  try FileUtility.url(name: "tests.dat")
            let fileHandle = try FileUtility.handle(url: fileUrl)
            let queue = QueueFile(fileHandle: fileHandle)
            let expectedOne = testData[0]
            let expectedTwo = testData[1]
            queue.add(expectedOne)
            queue.add(expectedTwo)
            
            // Confirm that the data was in the file before we cleared.
            let firstOffset = FileHeader.headerLength + FileElement.headerLength
            do { // first is as expected
                fileHandle.seek(toFileOffset: firstOffset)
                let data = fileHandle.readData(ofLength: expectedOne.count)
                XCTAssertEqual(expectedOne, data)
            }
            
            let secondOffset = firstOffset + UInt64(expectedOne.count) + FileElement.headerLength
            do { // second is as expected
                fileHandle.seek(toFileOffset: secondOffset)
                let data = fileHandle.readData(ofLength: expectedTwo.count)
                XCTAssertEqual(expectedTwo, data)
            }
            
            queue.remove(1)
            
            // second should still be there
            XCTAssertEqual(queue.peek()!, expectedTwo)
            
            do { // first should be gone
                fileHandle.seek(toFileOffset: firstOffset)
                let data = fileHandle.readData(ofLength: expectedOne.count)
                XCTAssertEqual(data, Data.init(repeating: 0, count: expectedOne.count))
            }
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testRemoveDoesNotCurrupt() {
        do {
            var queue = try newQueueFile()
            
            queue.add(testData[0])
            let expected = testData[1]
            queue.add(expected)
            
            queue.remove()
            
            queue = try newQueueFile()
            XCTAssertEqual(queue.peek()!, expected)
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    func testMultipleRemoveDoesNotCurrupt() {
        do {
            var queue = try newQueueFile()
            for data in testData {
                queue.add(data)
            }
            
            queue.remove(1)
            XCTAssertEqual(queue.size, 9)
            
            queue.remove(3)
            queue = try newQueueFile()
            XCTAssertEqual(queue.size, 6)
            XCTAssertEqual(queue.peek()!, testData[4])
            
            queue.remove(6)
            XCTAssertNil(queue.peek())
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testRemoveFromEmptyFileDoesNotCurrupt() {
        do {
            let queue = try newQueueFile()
            
            XCTAssertTrue(queue.isEmpty)
            queue.remove()
            XCTAssertTrue(queue.isEmpty)
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testRemoveZeroFromEmptyFileDoesNothing() {
        do {
            let queue = try newQueueFile()
            
            XCTAssertTrue(queue.isEmpty)
            queue.remove(0)
            XCTAssertTrue(queue.isEmpty)
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testRemoveZeroDoesNothing() {
        do {
            let queue = try newQueueFile()
            queue.add(testData[1])
            XCTAssertEqual(queue.size, 1)
            queue.remove(0)
            XCTAssertEqual(queue.size, 1)
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testRemoveBeyondBoundsClears() {
        do {
            let queue = try newQueueFile()
            queue.add(testData[1])
            XCTAssertEqual(queue.size, 1)
            queue.remove(10)
            XCTAssertTrue(queue.isEmpty)
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
    
    func testLargeFileAdditionShrinking() {
        do {
            let fileHandle = try newFileHandle()
            let queue = try newQueueFile(fileHandle: fileHandle)
          
            let bigString = """
                            Larger string of text, added multiple times.
                            Larger string of text, added multiple times.
                            Larger string of text, added multiple times.
                            Larger string of text, added multiple times.
                            Larger string of text, added multiple times.
                            Larger string of text, added multiple times.
                            Larger string of text, added multiple times.
                            Larger string of text, added multiple times.
                            """.data(using: .utf8)!
            
            let expectedElementSize = FileElement.headerLength + UInt64(bigString.count)
            let expectedFileSizeAfterAddition = FileHeader.headerLength + (12000 * expectedElementSize)
            let expectedFileSizeAterRemove = FileHeader.headerLength + (8000 * expectedElementSize) + expectedElementSize
            
            for _ in 0..<12000 { queue.add(bigString) }
            queue.remove(4000)
            XCTAssertEqual(fileHandle.seekToEndOfFile(), expectedFileSizeAfterAddition)
            queue.add(bigString)
            XCTAssertEqual(fileHandle.seekToEndOfFile(), expectedFileSizeAterRemove)
            
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }
}
