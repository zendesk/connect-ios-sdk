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

protocol EnvironmentStorable {
    var privateKey: String? { get set }
    init()
}

let EnvironmentStoragePrivateKey = "EnvironmentStoragePrivateKey"

final class EnvironmentStorage: EnvironmentStorable {
    static let name = "com.zendesk.connect.environment"
    private let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: EnvironmentStorage.name)!
    }

    var privateKey: String? {
        get {
            return defaults.string(forKey: EnvironmentStoragePrivateKey)
        }
        set {
            defaults.set(newValue, forKey: EnvironmentStoragePrivateKey)
        }
    }
}
