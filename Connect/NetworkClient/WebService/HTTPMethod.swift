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

/// Enum representation of common HTTP methods
///
/// - get: HTTP/GET method
/// - put: HTTP/PUT method
/// - post: HTTP/POST method
/// - delete: HTTP/DELETE method
enum HttpMethod<Body> {
    case get
    case put(Body)
    case post(Body)
    case delete
}

extension HttpMethod {
    
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
    
    func map<B>(f: (Body) -> B) -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .delete: return .delete
        case .post(let body):
            return .post(f(body))
        case .put(let body):
            return .post(f(body))
        }
    }
}

typealias EquatableHttpMethod = HttpMethod
extension EquatableHttpMethod : Equatable {
    
    static func ==(lhs: HttpMethod<Body>, rhs: HttpMethod<Body>) -> Bool {
        return lhs.method == rhs.method
    }
}
