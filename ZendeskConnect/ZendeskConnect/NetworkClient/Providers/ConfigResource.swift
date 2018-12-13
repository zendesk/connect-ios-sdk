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

/// ConfigResource is a simple struct to provide a simplified way to construct Resource instances
struct ConfigResource {
    static func config(platform: String, version: String) -> Resource<Empty, Config> {
        let pathParams = [
            "platform": platform,
            "version": version,
        ]
        let urlString = String.format(string: "/i/config/sdk/{platform}/{version}", with: pathParams)
        let url = URL(string: urlString)!
        return Resource(url: url, method: .get, response: Config.self)
    }
}
