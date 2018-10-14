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

class ConfigProvider: BaseProvider {
    /// Create a Config in Connect
    ///
    /// - Parameters:
    ///   - Config: Config model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func config(platform: String, version: String, completion: @escaping (Result<Config>) -> ()) {
        WebService(with: self.client).load(resource: ConfigResource.config(platform: platform , version: version )) { result in
            completion(result)
        }
    }
}
