/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation
import XCTest
import OHHTTPStubs
@testable import ZendeskConnect

final class ExpectationOperation: Operation {
    private let expectation: XCTestExpectation
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    override func main() {
        expectation.fulfill()
    }
}

struct IPMKeys {
    static let oid = "_oid"
    static let logo = "logo"
    static let heading = "heading"
    static let message = "message"
    static let messageFontColor = "messageFontColor"
    static let headingFontColor = "headingFontColor"
    static let backgroundColor = "backgroundColor"
    static let buttonText = "buttonText"
    static let buttonBackgroundColor = "buttonBackgroundColor"
    static let buttonTextColor = "buttonTextColor"
    static let action = "action"
    static let ttl = "ttl"
}

/// Default values for testing.
enum TestDefaults {
    static let configEndpoint = "/i/config/sdk/ios"
    static let apiKey = "1234"
    static let configBodyString = """
                                {
                                    "account" : {
                                        "prompt" : true
                                    },
                                    "enabled" : true,
                                }
                                """
    static let noPromptConfigBodyString = """
                                        {
                                            "account" : {
                                                "prompt" : false
                                            },
                                            "enabled" : true,
                                        }
                                        """
}

/// `OHHTTPStubsTestBlock` checking if a request contains some Connect specific HTTP headers.
///
/// - Parameter apiKey: API key to test for. Defaults to `TestDefaults.apiKey`.
/// - Returns: A `OHHTTPStubsTestBlock`. `true` if the request contains all the headers.
func headers(apiKey: String = TestDefaults.apiKey) -> OHHTTPStubsTestBlock {
    return { request in
        let headers = request.allHTTPHeaderFields ?? [:]
        let xClient = headers["X-Outbound-Client"] == "\(PlatformString)/\(ConnectVersionString)"
        let xGuid = headers["X-Outbound-GUID"] != nil
        let xKey = headers["X-Outbound-Key"] == apiKey
        XCTAssert(xClient, "X-Outbound-Client faild to match")
        XCTAssert(xGuid, "X-Outbound-GUID faild to match")
        XCTAssert(xKey, "X-Outbound-Key faild to match")
        return xClient && xGuid && xKey
    }
}

/// Tests HTTP message for the provider string. Uses ohhttpStubs_httpBody property
/// and converts to a string.
///
/// - Parameter string: Test value. Does the HTTP message contain this string?
/// - Returns: A `OHHTTPStubsTestBlock`. `true` if the value is contained in the message. `false` if the message is `nil`, or the value wasn't contained in the message.
func body(contains string: String) -> OHHTTPStubsTestBlock {
    return { request in
        
        guard
            let method = request.httpMethod,
            method == "POST" else {
            return false
        }
        
        guard let data = request.ohhttpStubs_httpBody else {
            XCTFail("Could not get message of request")
            return false
        }
        let bodyString = String.init(data: data, encoding: .utf8) ?? "Couldn't create string from data"
        let contains = bodyString.contains(string)
        XCTAssert(contains, "Matching string:\n\(string)\nNot found in request body string:\n\(bodyString)")
        return contains
    }
}

/// `OHHTTPStubsTestBlock` for `Connect` config endpoint.
///
/// - Returns: `OHHTTPStubsTestBlock` passing for `Connect` config endpoint.
func configEndpoint() -> OHHTTPStubsTestBlock {
    return { request -> Bool in
        guard let url = request.url?.absoluteString else { return false }
        return url.contains(TestDefaults.configEndpoint)
    }
}

/// Creates an `OHHTTPStubsResponseBlock` with a HTTP message from the `String` provided.
/// The provided expectation fulfill is delayed by half a second.
///
/// - Parameters:
///   - bodyString: A `String` to be converted to `Data`.
///   - expectation: An expectation to fulfill.
/// - Returns: Block for the response parameter in `OHHTTPStubs sub(condition:response:)`, with `bodyString` converted to `Data`.
func body(with bodyString: String, expectation: XCTestExpectation? = nil) -> OHHTTPStubsResponseBlock {
    let data = bodyString.data(using: .utf8)!
    return response(status: 200, data: data, fulfill: expectation)
}

/// Return a 200 and optionally fulfill `XCTestExpectation`.
/// The provided expectation fulfill is delayed by half a second.
///
/// - Parameter expectation: An expectation to fulfill.
/// - Returns: Block for the response parameter in `OHHTTPStubs sub(condition:response:)`.
func OK(fulfill expectation: XCTestExpectation? = nil) -> OHHTTPStubsResponseBlock {
    return response(status: 200, data: Data(), fulfill: expectation)
}


/// Wraps creation of an OHHTTPStubsResponseBlock and fulfillment of an expectation.
///
/// - Parameters:
///   - status: HTTP status of the response.
///   - data: Response data.
///   - expectation: An expectation to fulfill.
/// - Returns: Block for the response parameter in `OHHTTPStubs sub(condition:response:)`.
func response(status: Int32, data: Data = Data(), fulfill expectation: XCTestExpectation? = nil) -> OHHTTPStubsResponseBlock {
    return { request -> OHHTTPStubsResponse in
        expectation?.delayedFulfill(delay:  .now() + .milliseconds(500))
        return OHHTTPStubsResponse(data: data, statusCode: status, headers: nil)
    }
}

extension XCTestExpectation {
    
    /// Delays the fulfill method until the dispatch time provided.
    ///
    /// - Parameter delay: `DispatchTime`.
    func delayedFulfill(delay: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.fulfill()
        }
    }
}
