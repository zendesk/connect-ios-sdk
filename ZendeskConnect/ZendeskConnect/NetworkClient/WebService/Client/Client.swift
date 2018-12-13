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

/// Client struct use to model the connection parameters for communicating with a Zendesk instance
struct Client {
    let requestDecorator: [RequestDecorator]
    let host: URL
    let session: URLSession

    /// Init method of the client
    ///
    /// - Parameters:
    ///   - host: URL of the host the Client will connect to
    ///   - userAgent: String User-Agent string to be sent on the out-going HTTP requests
    ///   - requestDecorator: An instant which conforms to the RequestDecorator protocol, **Default is empty array**
    init(host: URL, requestDecorator: [RequestDecorator] = []) {
        self.host = host
        self.requestDecorator = requestDecorator

        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        session = URLSession(configuration: urlSessionConfiguration)
    }
}
