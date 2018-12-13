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

final class ConfigStorage {
    static let name = "com.zendesk.connect.config"
    private let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults(suiteName: ConfigStorage.name)!
    }
}

protocol ConfigWritable {
    func store(config: Config)
    func clear()
}

protocol ConfigReadable {
    func readConfig() -> Config?
}

protocol ConfigStorable: ConfigWritable, ConfigReadable {
    init()
}

extension ConfigStorage: ConfigStorable {}

extension ConfigStorage: ConfigWritable {

    func clear() {
        defaults.removePersistentDomain(forName: ConfigStorage.name)
    }
    
    func store(config: Config) {
        do {
            let configData = try DefaultConverter().toData(config)
            defaults.set(configData, forKey: "config")
            Logger.debug("Stored config.")
        } catch {
            Logger.debug("Failed to convert config: \(error.localizedDescription)")
        }
    }
}
    
extension ConfigStorage: ConfigReadable {
    
    func readConfig() -> Config? {
        guard let data = defaults.data(forKey: "config") else { return nil }
        return try? DefaultConverter().from(data)
    }
}
