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

class EventProvider: BaseProvider {
    /// Create a Event in Connect
    ///
    /// - Parameters:
    ///   - Event: Event model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func track(body: Event, completion: @escaping (Result<Empty>) -> ()) {
        WebService(with: self.client).load(resource: EventResource.track(body: body )) { result in
            completion(result)
        }
    }
    /// Create a Event in Connect
    ///
    /// - Parameters:
    ///   - Event: Event model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func trackBatch(body: [Event], completion: @escaping (Result<Empty>) -> ()) {
        WebService(with: self.client).load(resource: EventResource.trackBatch(body: body )) { result in
            completion(result)
        }
    }
}
