/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation
import XCTest
@testable import ZendeskConnect

class IPMTests: XCTestCase {

    let ipmDictionary: [AnyHashable: Any] = [
        IPMKeys.oid: "12345",
        IPMKeys.logo: "https://image.com/image.jpg",
        IPMKeys.heading: "I'm an IPM",
        IPMKeys.message: "I have a message",
        IPMKeys.messageFontColor: "#000000",
        IPMKeys.headingFontColor: "#000000",
        IPMKeys.backgroundColor: "#FFFFFF",
        IPMKeys.buttonText: "Pie!",
        IPMKeys.buttonBackgroundColor: "#787879",
        IPMKeys.buttonTextColor: "#FFFFFF",
        IPMKeys.action: "guide://subdomain/articles?articleId=pie",
        IPMKeys.ttl: "100"
    ]

    let notFullIPMDictionary: [AnyHashable: Any] = [
        IPMKeys.oid: "12345",
        IPMKeys.logo: "https://image.com/image.jpg",
        IPMKeys.heading: "I'm an IPM",
        //IPMKeys.message: "I have a message", //Intentional missing field
        IPMKeys.messageFontColor: "#000000",
        IPMKeys.headingFontColor: "#000000",
        IPMKeys.backgroundColor: "#FFFFFF",
        IPMKeys.buttonText: "Pie!",
        IPMKeys.buttonBackgroundColor: "#787879",
        IPMKeys.buttonTextColor: "#FFFFFF",
        IPMKeys.action: "guide://subdomain/articles?articleId=pie",
        IPMKeys.ttl: "100"
    ]

    func testIsIPM() {
        guard let ipm = decode(dictionary: ipmDictionary, to: IPM.self) else {
            XCTFail("This should be a valid IPM type")
            return
        }

        XCTAssertTrue(ipm.instanceIdentifier == "12345")
        XCTAssertTrue(ipm.logo == URL(string: "https://image.com/image.jpg"))
        XCTAssertTrue(ipm.heading == "I'm an IPM")
        XCTAssertTrue(ipm.message == "I have a message")
        XCTAssertTrue(ipm.messageFontColor == "#000000")
        XCTAssertTrue(ipm.headingFontColor == "#000000")
        XCTAssertTrue(ipm.backgroundColor == "#FFFFFF")
        XCTAssertTrue(ipm.buttonText == "Pie!")
        XCTAssertTrue(ipm.buttonBackgroundColor == "#787879")
        XCTAssertTrue(ipm.buttonTextColor == "#FFFFFF")
        XCTAssertTrue(ipm.action == URL(string: "guide://subdomain/articles?articleId=pie"))
        XCTAssertTrue(ipm.timeToLive == 100)
    }

    func testNotFullIPM() {
        let nonIPM = decode(dictionary: notFullIPMDictionary, to: IPM.self)
        XCTAssertNil(nonIPM)
    }

    func testEmptyLogoInDictionary() {
        let dictionary: [AnyHashable: Any] = [
            IPMKeys.oid: "23456",
            IPMKeys.logo: "",
            IPMKeys.heading: "I'm an IPM",
            IPMKeys.message: "I have a message",
            IPMKeys.messageFontColor: "#000000",
            IPMKeys.headingFontColor: "#000000",
            IPMKeys.backgroundColor: "#FFFFFF",
            IPMKeys.buttonText: "Pie!",
            IPMKeys.buttonBackgroundColor: "#787879",
            IPMKeys.buttonTextColor: "#FFFFFF",
            IPMKeys.action: "guide://subdomain/articles?articleId=pie",
            IPMKeys.ttl: "100"
        ]

        guard let ipm = decode(dictionary: dictionary, to: IPM.self) else {
            XCTFail("This should be a valid IPM type with no logo as a result of an empty string in the dictionary")
            return
        }

        XCTAssertTrue(ipm.instanceIdentifier == "23456")
        XCTAssertTrue(ipm.logo == nil)
        XCTAssertTrue(ipm.action == URL(string: "guide://subdomain/articles?articleId=pie"))
    }

    func testEmptyActionInDictionary() {
        let dictionary: [AnyHashable: Any] = [
            IPMKeys.oid: "34567",
            IPMKeys.logo: "https://image.com/image.jpg",
            IPMKeys.heading: "I'm an IPM",
            IPMKeys.message: "I have a message",
            IPMKeys.messageFontColor: "#000000",
            IPMKeys.headingFontColor: "#000000",
            IPMKeys.backgroundColor: "#FFFFFF",
            IPMKeys.buttonText: "Pie!",
            IPMKeys.buttonBackgroundColor: "#787879",
            IPMKeys.buttonTextColor: "#FFFFFF",
            IPMKeys.action: "",
            IPMKeys.ttl: "100"
        ]

        guard let ipm = decode(dictionary: dictionary, to: IPM.self) else {
            XCTFail("This should be a valid IPM type with no action as a result of an empty string in the dictionary")
            return
        }

        XCTAssertTrue(ipm.instanceIdentifier == "34567")
        XCTAssertTrue(ipm.logo == URL(string: "https://image.com/image.jpg"))
        XCTAssertTrue(ipm.action == nil)
    }

    func testNoLogoInDictionary() {
        let dictionary: [AnyHashable: Any] = [
            IPMKeys.oid: "45678",
            IPMKeys.heading: "I'm an IPM",
            IPMKeys.message: "I have a message",
            IPMKeys.messageFontColor: "#000000",
            IPMKeys.headingFontColor: "#000000",
            IPMKeys.backgroundColor: "#FFFFFF",
            IPMKeys.buttonText: "Pie!",
            IPMKeys.buttonBackgroundColor: "#787879",
            IPMKeys.buttonTextColor: "#FFFFFF",
            IPMKeys.action: "guide://subdomain/articles?articleId=pie",
            IPMKeys.ttl: "100"
        ]

        guard let ipm = decode(dictionary: dictionary, to: IPM.self) else {
            XCTFail("This should be a valid IPM type with no logo as a result of it missing from the dictionary")
            return
        }

        XCTAssertTrue(ipm.instanceIdentifier == "45678")
        XCTAssertTrue(ipm.logo == nil)
        XCTAssertTrue(ipm.action == URL(string: "guide://subdomain/articles?articleId=pie"))
    }

    func testNoActionInDictionary() {
        let dictionary: [AnyHashable: Any] = [
            IPMKeys.oid: "56789",
            IPMKeys.logo: "https://image.com/image.jpg",
            IPMKeys.heading: "I'm an IPM",
            IPMKeys.message: "I have a message",
            IPMKeys.messageFontColor: "#000000",
            IPMKeys.headingFontColor: "#000000",
            IPMKeys.backgroundColor: "#FFFFFF",
            IPMKeys.buttonText: "Pie!",
            IPMKeys.buttonBackgroundColor: "#787879",
            IPMKeys.buttonTextColor: "#FFFFFF",
            IPMKeys.ttl: "100"
        ]

        guard let ipm = decode(dictionary: dictionary, to: IPM.self) else {
            XCTFail("This should be a valid IPM type with no action as a result of it missing from the dictionary")
            return
        }

        XCTAssertTrue(ipm.instanceIdentifier == "56789")
        XCTAssertTrue(ipm.logo == URL(string: "https://image.com/image.jpg"))
        XCTAssertTrue(ipm.action == nil)
    }
}
