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

extension NSMutableURLRequest {
    convenience init<A,R>(resource: Resource<A,R>, host: URL) {
        let requestURL = URL(string: resource.url.absoluteString, relativeTo: host)!
        self.init(url: requestURL)

        httpMethod = resource.method.method
        switch resource.method {
            case .post(let data), .put(let data):
                httpBody = data
                break
            default:
                //Intentionally empty
                break
        }
        if case let .post(data) = resource.method {
            httpBody = data
        }

        self.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        self.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
    }
}
