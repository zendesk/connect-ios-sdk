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

private let IPMBasicKey = "ConnectIPMBasicKey"
private let IPMReceivedDateKey = "ConnectIPMReceivedDateKey"

protocol IPMSharedStorageModule {
    var storedIPM: IPM? { get set }
    var storedIdentifier: String { get }
    func clearStorage()
}

struct ConnectIPMSharedStorageModule: IPMSharedStorageModule {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    var storedIPM: IPM? {
        get {
            guard let savedValue = defaults.object(forKey: IPMBasicKey) as? Data else {
                return nil
            }

            let decoder = JSONDecoder()
            return try? decoder.decode(IPM.self, from: savedValue)
        }
        set {
            let encoder = JSONEncoder()
            guard let encoded = try? encoder.encode(newValue) else {
                return
            }

            defaults.set(encoded, forKey: IPMBasicKey)
        }
    }

    var storedIdentifier: String {
        get {
            return storedIPM?.instanceIdentifier ?? ""
        }
    }

    func clearStorage() {
        defaults.removeObject(forKey: IPMBasicKey)
        defaults.removeObject(forKey: IPMReceivedDateKey)
    }
}
