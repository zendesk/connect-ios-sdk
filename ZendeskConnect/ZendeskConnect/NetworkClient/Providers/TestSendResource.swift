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

/// TestSendResource is a simple struct to provide a simplified way to construct Resource instances
struct TestSendResource {
    static func pairDevice(platform: String = "ios", body: PairDevice) -> Resource<PairDevice, Empty> {
        let pathParams = [
            "platform": platform,
        ]
        let urlString = String.format(string: "/i/testsend/push/pair/{platform}", with: pathParams)
        let url = URL(string: urlString)!
        return Resource(url: url, method: .post(body), response: Empty.self, keyEncodingStrategy: .useDefaultKeys)
    }
}
