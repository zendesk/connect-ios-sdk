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

class MetricsProvider: BaseProvider {
    /// Create a Metrics in Connect
    ///
    /// - Parameters:
    ///   - Metrics: Metrics model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func opened(platform: String = "ios", body: PushBasicMetric, completion: @escaping (Result<Empty>) -> Void) {
        WebService(with: client).load(resource: MetricsResource.opened(platform: platform, body: body)) { result in
            completion(result)
        }
    }

    /// Create a Metrics in Connect
    ///
    /// - Parameters:
    ///   - Metrics: Metrics model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func received(platform: String = "ios", body: PushBasicMetric, completion: @escaping (Result<Empty>) -> Void) {
        WebService(with: client).load(resource: MetricsResource.received(platform: platform, body: body)) { result in
            completion(result)
        }
    }

    /// Create a Metrics in Connect
    ///
    /// - Parameters:
    ///   - Metrics: Metrics model to be used as the source
    ///   - completion: Closure invoked on the completion of the API call, returns a Result object which provides both Success and Error semantics
    func uninstallTracker(platform: String = "ios", body: UninstallTracker, completion: @escaping (Result<Empty>) -> Void) {
        WebService(with: client).load(resource: MetricsResource.uninstallTracker(platform: platform, body: body)) { result in
            completion(result)
        }
    }
}
