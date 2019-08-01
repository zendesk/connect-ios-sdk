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

/// WebService is a simple class representing the act of making a HTTP request.
final class WebService {
    let client: Client

    /// Init
    ///
    /// - Parameters:
    ///   - session: A configured `URLSession` instance.
    ///   - host: `URL` host to which requests will be made.
    init(with client: Client) {
        self.client = client
    }

    /// Load method takes a configured `Resource` model, fetches the required data and calls the delegated parse method in `Resource`.
    ///
    /// - Parameters:
    ///   - resource: `Resource` instance.
    ///   - completion: Completion block that gets executed on completion of the underlying HTTP call.
    func load<A, R>(resource: Resource<A, R>, completion: @escaping (Result<R>) -> Void) {
        var urlRequest = NSMutableURLRequest(resource: resource, host: client.host) as URLRequest

        client.requestDecorator.forEach { decorator in
            urlRequest.addValue(decorator.headerValue, forHTTPHeaderField: decorator.headerKey)
        }

        client.session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                if let error = error {
                    completion(Result<R>.failure(error))
                }
                return
            }
            completion(resource.parse(data, response))
        }.resume()
    }
}
