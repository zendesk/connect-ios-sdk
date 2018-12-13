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

extension String {
    static func format(string: String, with dictionary: Dictionary<String, String>) -> String {
        var replacement = string
        for (key, value) in dictionary {
            replacement = replacement.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return replacement
    }
}
