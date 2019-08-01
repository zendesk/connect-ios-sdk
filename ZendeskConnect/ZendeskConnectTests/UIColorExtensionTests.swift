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

class UIColorExtensionTests: XCTestCase {

    func testHexColourWithHash() {
        guard let pinkColour = UIColor(hexString: "#DF2E90") else {
            XCTFail("Should be a valid colour")
            return
        }

        XCTAssertTrue(pinkColour == .coolPink)
    }

    func testHexColourWithoutHash() {
        guard let greyColour = UIColor(hexString: "787879") else {
            XCTFail("Should be a valid colour")
            return
        }

        XCTAssertTrue(greyColour == .coolGrey)
    }

    func testHexColourWithIncorrectValue() {
        let invalidColour = UIColor(hexString: "minions")
        XCTAssertTrue(invalidColour == nil)
    }

    func testHexColourWithIncorrectLength() {
        let invalidLongColour = UIColor(hexString: "fffffffffffffffffffff")
        XCTAssertTrue(invalidLongColour == nil)

        let invalidShortColour = UIColor(hexString: "fffff")
        XCTAssertTrue(invalidShortColour == nil)
    }
}
