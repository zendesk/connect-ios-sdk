/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import XCTest
@testable import ZendeskConnect

enum MockError: Error {
    case error
}

final class MockMetricsProvider: MetricsProvider {
    private let successfulResult: Bool

    init(with client: Client, successfulResult: Bool) {
        self.successfulResult = successfulResult
        super.init(with: client)
    }

    override func opened(platform: String = "ios", body: PushBasicMetric, completion: @escaping (Result<Empty>) -> Void) {
        successfulResult ? completion(Result<Empty>.success(Empty(), nil)) : completion(Result<Empty>.failure(MockError.error))
    }

    override func received(platform: String = "ios", body: PushBasicMetric, completion: @escaping (Result<Empty>) -> Void) {
        successfulResult ? completion(Result<Empty>.success(Empty(), nil)) : completion(Result<Empty>.failure(MockError.error))
    }

    override func uninstallTracker(platform: String = "ios", body: UninstallTracker, completion: @escaping (Result<Empty>) -> Void) {
        successfulResult ? completion(Result<Empty>.success(Empty(), nil)) : completion(Result<Empty>.failure(MockError.error))
    }
}
