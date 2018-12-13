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

class TestSendProvider: BaseProvider {
    /// Create a TestSend in Connect
    ///
    /// - Parameters:
    ///   - TestSend: TestSend model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func pairDevice(platform: String = "ios", body: PairDevice, completion: @escaping (Result<Empty>) -> Void) {
        WebService(with: client).load(resource: TestSendResource.pairDevice(platform: platform, body: body)) { result in
            completion(result)
        }
    }
}
