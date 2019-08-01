/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation

func decode<T: Codable>(dictionary: [AnyHashable: Any], to: T.Type) -> T? {
    do {
        let json = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        let decoder = JSONDecoder()
        let value = try decoder.decode(to, from: json)
        return value
    } catch {
        Logger.debug("This dictionary did not decode properly: \(error.localizedDescription)")
        return nil
    }
}
