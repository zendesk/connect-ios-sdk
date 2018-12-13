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

class IdentifyProvider: BaseProvider {
    /// Create a Identify in Connect
    ///
    /// - Parameters:
    ///   - Identify: Identify model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func identify(body: User, completion: @escaping (Result<Empty>) -> Void) {
        WebService(with: client).load(resource: IdentifyResource.identify(body: body)) { result in
            completion(result)
        }
    }

    /// Create a Identify in Connect
    ///
    /// - Parameters:
    ///   - Identify: Identify model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func identifyBatch(body: [User], completion: @escaping (Result<Empty>) -> Void) {
        WebService(with: client).load(resource: IdentifyResource.identifyBatch(body: body)) { result in
            completion(result)
        }
    }
}
