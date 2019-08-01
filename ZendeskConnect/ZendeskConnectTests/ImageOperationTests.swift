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
@testable import ZendeskConnect

final class ImageOperationTests: XCTestCase {

    var operationQueue: OperationQueue!

    override func setUp() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
    }

    func testNilURLResultsInNilImage() {
        let resource = ImageResource(remoteURL: nil)
        let operation = ImageOperation(imageResource: resource)
        operationQueue.addOperations([operation], waitUntilFinished: true)
        XCTAssertNil(resource.image)
    }

    func testNonImageURLResultsInNilImage() {
        let resource = ImageResource(remoteURL: URL(string: "https://example.com"))
        let operation = ImageOperation(imageResource: resource)
        operationQueue.addOperations([operation], waitUntilFinished: true)
        XCTAssertNil(resource.image)
    }

    func testNonImageLocalURLResultsInNilImage() {
        let resource = ImageResource(remoteURL: URL(string: "/"))
        let operation = ImageOperation(imageResource: resource)
        operationQueue.addOperations([operation], waitUntilFinished: true)
        XCTAssertNil(resource.image)
    }

    func testImageLocalURLResultsInImage() {
        let testImageURL = Bundle(for: type(of: self)).url(forResource: "test-image", withExtension: ".png")
        let resource = ImageResource(remoteURL: testImageURL)
        let operation = ImageOperation(imageResource: resource)
        operationQueue.addOperations([operation], waitUntilFinished: true)
        XCTAssertNotNil(resource.image)
    }

}
