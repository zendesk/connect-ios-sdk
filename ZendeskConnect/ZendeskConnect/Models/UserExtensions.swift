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

extension User {

    /// Creates a blank user with a UUID for a userId.
    ///
    /// - Returns: An anonymous user.
    static func createAnonymous() -> User {
        return User(userId: UUID().uuidString)
    }


    /// Returns a new copy of user with userId replaced with aliasId.
    ///
    /// - Parameter aliasId: New id to replace userId.
    /// - Returns: A new copy of user with userId replaced with aliasId.
    public func aliased(aliasId: String) -> User {
        return User(firstName: firstName,
                    lastName: lastName,
                    email: email,
                    attributes: attributes,
                    userId: aliasId,
                    previousId: userId,
                    phoneNumber: phoneNumber,
                    groupId: groupId,
                    groupAttributes: groupAttributes,
                    timezone: timezone,
                    gcm: gcm,
                    apns: apns)
    }
}
