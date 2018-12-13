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

let ConnectPrePromptHasAcceptedPermissionKey = "ConnectPrePromptHasAcceptedPermissionKey"

protocol PushSharedStorageModule {
    var prePromptHasAcceptedPermission: Bool { get set }
}

struct ConnectPushSharedStorageModule: PushSharedStorageModule {

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    var prePromptHasAcceptedPermission: Bool {
        get {
            return defaults.bool(forKey: ConnectPrePromptHasAcceptedPermissionKey)
        }
        set {
            defaults.set(newValue, forKey: ConnectPrePromptHasAcceptedPermissionKey)
        }
    }
}
