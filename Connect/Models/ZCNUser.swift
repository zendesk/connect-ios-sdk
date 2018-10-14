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


@objc(ZCNUser)
/// Objective C wrapper for swift User model.
public class ZCNUser: NSObject {
    let internalUser: User
    
    
    /// User id to use with ZCNEvent for tracking. 
    @objc public var userId: String {
        return internalUser.userId
    }

    init(user: User) {
        internalUser = user
    }
    
    
    /// Creates a ZCNUser with the details provided.
    ///
    /// - Parameters:
    ///   - firstName: first name of user if known.
    ///   - lastName: last name of user if known.
    ///   - email: email of user if known.
    ///   - attributes: any attributes to associate with the user.
    ///   - userId: an id for the user to be sent with track events.
    ///   - previousId: used when aliasing a user. This will generaly be the value that was last used in userId.
    ///   - phoneNumber: phone number of user if known.
    ///   - groupId: grouping this user by id.
    ///   - groupAttributes: attributes for the group.
    ///   - timezone: the timezone of user if known.
    ///   - gcm: not use in iOS.
    ///   - apns: array of apns tokens.
    @objc public init(firstName: String?,
                      lastName: String?,
                      email: String?,
                      attributes: [String: Any]?,
                      userId: String,
                      previousId: String?,
                      phoneNumber: String?,
                      groupId: String?,
                      groupAttributes: [String: Any]?,
                      timezone: String?,
                      gcm: [String]?,
                      apns: [String]?) {
        
        internalUser = User(firstName: firstName,
                            lastName: lastName,
                             email: email,
                             attributes: attributes,
                             userId: userId,
                             previousId: previousId,
                             phoneNumber: phoneNumber,
                             groupId: groupId,
                             groupAttributes: groupAttributes,
                             timezone: timezone,
                             gcm: gcm,
                             apns: apns)
    }
}

extension ZCNUser {
    
    static func createAnonymous() -> ZCNUser {
        return ZCNUser(user:User.createAnonymous())
    }
    
    @objc public static func alias(previousUser: ZCNUser, newId: String) -> ZCNUser {
        let user = previousUser.internalUser
        return ZCNUser(user: User.alias(previousUser: user, newId: newId))
    }
}

