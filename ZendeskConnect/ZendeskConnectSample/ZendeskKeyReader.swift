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

final class ZendeskKeyReader {
    
    private typealias ZendeskKeys = [ZendeskKey]
    
    func readKeys() -> [ZendeskKey] {
        var keys: [ZendeskKey] = []
        
        guard let path = Bundle.main.path(forResource: "ZendeskKeys", ofType: "plist") else {
            return keys
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            keys = try PropertyListDecoder().decode(ZendeskKeys.self, from: data)
        }
        catch {
            print("Error", error)
        }
        
        return keys
    }
}
