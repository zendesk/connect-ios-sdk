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


final class UserStorage {
    static let name = "com.zendesk.connect.user"
    private let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults(suiteName: UserStorage.name)!
    }
}

protocol UserWritable {
    func store(_ user: User)
    func store(_ token: Data)
    func clear()
}

protocol UserReadable {
    func readUser() -> User?
    func readToken() -> Data?
}

protocol UserStorable: UserWritable, UserReadable {
    init()
}
extension UserStorage: UserStorable {}

extension UserStorage: UserWritable {
    func store(_ user: User) {
        do {
            let userData = try DefaultConverter().toData(user)
            defaults.setValue(userData, forKey: "user")
        } catch {
            Logger.debug("Failed to convert user: \(error.localizedDescription)")
        }
    }
    
    func store(_ token: Data) {
        defaults.set(token, forKey: "token")
    }
    
    func clear() {
        defaults.removePersistentDomain(forName: UserStorage.name)
    }
}

extension UserStorage: UserReadable {
    
    func readUser() -> User? {
        guard let data = defaults.data(forKey: "user") else { return nil }
        return try? DefaultConverter().from(data)
    }
    
    func readToken() -> Data? {
       return defaults.data(forKey: "token")
    }
}

