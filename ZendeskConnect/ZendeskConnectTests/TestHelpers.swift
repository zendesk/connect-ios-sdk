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


/// Default values for testing
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

/// Test block checking if a request contains some connect specific HTTP headers.
///
/// - Parameter apiKey: API key to test for. Defaults to TestDefaults.apiKey.
/// - Returns: a test stubs test block. true if the requset contains all the headers.
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

/// Tests HTTP body for the provider string. Uses ohhttpStubs_httpBody property
/// and converts to a string.
///
/// - Parameter string: test value. Does the HTTP body contain this string?
/// - Returns: a stubs test block. true if the value is contained in the body. falso if the body is nil, or the value wasn't contained in the body.
func body(contains string: String) -> OHHTTPStubsTestBlock {
    return { request in
        
        guard
            let method = request.httpMethod,
            method == "POST" else {
            return false
        }
        
        guard let data = request.ohhttpStubs_httpBody else {
            XCTFail("Could not get body of request")
            return false
        }
        let bodyString = String.init(data: data, encoding: .utf8) ?? "Couldn't create string from data"
        let contains = bodyString.contains(string)
        XCTAssert(contains, "Matching string:\n\(string)\nNot found in request body string:\n\(bodyString)")
        return contains
    }
}

/// Stubs test block for connect config endpoint.
///
/// - Returns: stubs test block passing for connect config endpoint.
func configEndpoint() -> OHHTTPStubsTestBlock {
    return { request -> Bool in
        guard let url = request.url?.absoluteString else { return false }
        return url.contains(TestDefaults.configEndpoint)
    }
}

/// Creates an OHHTTP stubs response block with a HTTP body from the string provided.
/// The provided expectation fulfill is delayed by half a second.
///
/// - Parameters:
///   - bodyString: body string to be converted to data.
///   - expectation: an expectation to fulfill
/// - Returns: block for the response parameter in OHHTTPStubs sub(condition:response:), with bodyString converted to data.
func body(with bodyString: String, expectation: XCTestExpectation? = nil) -> OHHTTPStubsResponseBlock {
    let data = bodyString.data(using: .utf8)!
    return response(status: 200, data: data, fulfill: expectation)
}

/// Return a 200 and optionally fulfill XCTestExpectation.
/// The provided expectation fulfill is delayed by half a second.
///
/// - Parameter expectation: an expectation to fulfill
/// - Returns: block for the response parameter in OHHTTPStubs sub(condition:response:).
func OK(fulfill expectation: XCTestExpectation? = nil) -> OHHTTPStubsResponseBlock {
    return response(status: 200, data: Data(), fulfill: expectation)
}


/// Wraps creation of an OHHTTP stub response block and fulfillment of an expectation.
///
/// - Parameters:
///   - status: HTTP status of the response
///   - data: response data
///   - expectation: an expectation to fulfill
/// - Returns: block for the response parameter in OHHTTPStubs sub(condition:response:).
func response(status: Int32, data: Data = Data(), fulfill expectation: XCTestExpectation? = nil) -> OHHTTPStubsResponseBlock {
    return { request -> OHHTTPStubsResponse in
        expectation?.delayedFulfill(delay:  .now() + .milliseconds(500))
        return OHHTTPStubsResponse(data: data, statusCode: status, headers: nil)
    }
}

extension XCTestExpectation {
    
    /// Delays the fulfill method until the dispatch time provided.
    ///
    /// - Parameter delay: dispatch time.
    func delayedFulfill(delay: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.fulfill()
        }
    }
}
