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


final class ZendeskKeyStorage {
    
    private let storageKey = "ZendeskKeyStorageKey"
    private let name = "com.zendesk.connect.key"
    private let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults(suiteName: name)!
    }
    
    var selectedZendeskKey: ZendeskKey? {
        get {
            guard let savedValue = defaults.object(forKey: storageKey) as? Data else {
                return nil
            }
            
            let decoder = JSONDecoder()
            return try? decoder.decode(ZendeskKey.self, from: savedValue)
        }
        set {
            let encoder = JSONEncoder()
            guard let encoded = try? encoder.encode(newValue) else {
                return
            }
            
            defaults.set(encoded, forKey: storageKey)
        }
    }
}
