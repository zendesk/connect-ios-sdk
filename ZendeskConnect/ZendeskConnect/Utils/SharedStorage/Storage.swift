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


/// Shared storage for connect. Contains modules for storing and retrieving values.
///
/// `Storage` is scoped by modules. If you want to add something to shared storage,
/// either add it to a module that exists already, or create a module and add it to `Storage`.
///
/// A module is a logical separation of `Storage`.
final class Storage {
    static let name = "com.zendesk.connect.shared"
    fileprivate let defaults: UserDefaults

    /// General storage for push related data.
    var pushModule: PushSharedStorageModule
    /// Storage for IPM data.
    var ipmModule: IPMSharedStorageModule

    static let shared = Storage()

    private init() {
        defaults = UserDefaults(suiteName: Storage.name)!
        pushModule = ConnectPushSharedStorageModule(defaults: defaults)
        ipmModule = ConnectIPMSharedStorageModule(defaults: defaults)
    }
}

