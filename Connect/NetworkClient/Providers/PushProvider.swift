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

class PushProvider: BaseProvider {
    /// Create a Push in Connect
    ///
    /// - Parameters:
    ///   - Push: Push model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func permissionGranted(body: PermissionRequested, completion: @escaping (Result<Empty>) -> ()) {
        WebService(with: self.client).load(resource: PushResource.permissionGranted(body: body )) { result in
            completion(result)
        }
    }
    /// Create a Push in Connect
    ///
    /// - Parameters:
    ///   - Push: Push model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func permissionRequested(body: PermissionRequested, completion: @escaping (Result<Empty>) -> ()) {
        WebService(with: self.client).load(resource: PushResource.permissionRequested(body: body )) { result in
            completion(result)
        }
    }
    /// Create a Push in Connect
    ///
    /// - Parameters:
    ///   - Push: Push model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func register(platform: String = "apns", body: PushRegistration, completion: @escaping (Result<Empty>) -> ()) {
        WebService(with: self.client).load(resource: PushResource.register(platform: platform , body: body )) { result in
            completion(result)
        }
    }
    /// Create a Push in Connect
    ///
    /// - Parameters:
    ///   - Push: Push model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func unregister(platform: String = "apns", body: PushRegistration, completion: @escaping (Result<Empty>) -> ()) {
        WebService(with: self.client).load(resource: PushResource.unregister(platform: platform , body: body )) { result in
            completion(result)
        }
    }
}
