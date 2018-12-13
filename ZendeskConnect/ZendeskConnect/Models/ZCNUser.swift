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


/// Objective C wrapper for swift User model.
@objc(ZCNUser)
public class ZCNUser: NSObject {
    let internalUser: User

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
    ///   - gcm: not used on iOS.
    ///   - apns: array of apns tokens.
    @objc
    public init(firstName: String?,
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

    /// first name of user if known.
    @objc
    public var firstName: String? {
        return internalUser.firstName
    }

    /// last name of user if known.
    @objc
    public var lastName: String? {
        return internalUser.lastName
    }

    /// email of user if known.
    @objc
    public var email: String? {
        return internalUser.email
    }

    /// any attributes to associate with the user.
    @objc
    public var attributes: [String: Any]? {
        return internalUser.attributes
    }

    /// an id for the user to be sent with track events.
    @objc
    public var userId: String {
        return internalUser.userId
    }

    /// used when aliasing a user. This will generally be the value that was last used in userId.
    @objc
    public var previousId: String? {
        return internalUser.previousId
    }

    /// phone number of user if known.
    @objc
    public var phoneNumber: String? {
        return internalUser.phoneNumber
    }

    /// grouping this user by id.
    @objc
    public var groupId: String? {
        return internalUser.groupId
    }

    /// attributes for the group.
    @objc
    public var groupAttributes: [String: Any]? {
        return internalUser.groupAttributes
    }

    /// the timezone of user if known.
    @objc
    public var timezone: String? {
        return internalUser.timezone
    }

    /// not used on iOS.
    @objc
    public var gcm: [String]? {
        return internalUser.gcm
    }

    /// array of apns tokens.
    @objc
    public var apns: [String]? {
        return internalUser.apns
    }

    /// Returns a new copy of user with userId replaced with aliasId.
    ///
    /// - Parameter aliasId: new id to replace user id.
    /// - Returns: a new copy of user with userId replaced with aliasId.
    @objc
    public func aliased(aliasId: String) -> ZCNUser {
        return ZCNUser(user: internalUser.aliased(aliasId: aliasId))
    }
}

