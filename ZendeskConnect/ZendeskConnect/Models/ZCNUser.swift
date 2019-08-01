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

/// Objective C wrapper for Swift User model.
@objc(ZCNUser)
public class ZCNUser: NSObject {
    let internalUser: User

    init(user: User) {
        internalUser = user
    }
    
    /// Creates a ZCNUser with the details provided.
    ///
    /// - Parameters:
    ///   - firstName: First name of user if known.
    ///   - lastName: Last name of user if known.
    ///   - email: Email of user if known.
    ///   - attributes: Any attributes to associate with the user.
    ///   - userId: An id for the user to be sent with track events.
    ///   - previousId: Used when aliasing a user. This will generally be the value that was last used in userId.
    ///   - phoneNumber: Phone number of user if known.
    ///   - groupId: Grouping this user by id.
    ///   - groupAttributes: Attributes for the group.
    ///   - timezone: The timezone of user if known.
    ///   - gcm: Not used on iOS.
    ///   - apns: Array of apns tokens.
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

    /// First name of user if known.
    @objc
    public var firstName: String? {
        return internalUser.firstName
    }

    /// Last name of user if known.
    @objc
    public var lastName: String? {
        return internalUser.lastName
    }

    /// Email of user if known.
    @objc
    public var email: String? {
        return internalUser.email
    }

    /// Any attributes to associate with the user.
    @objc
    public var attributes: [String: Any]? {
        return internalUser.attributes
    }

    /// An id for the user to be sent with track events.
    @objc
    public var userId: String {
        return internalUser.userId
    }

    /// Used when aliasing a user. This will generally be the value that was last used in userId.
    @objc
    public var previousId: String? {
        return internalUser.previousId
    }

    /// Phone number of user if known.
    @objc
    public var phoneNumber: String? {
        return internalUser.phoneNumber
    }

    /// Grouping this user by id.
    @objc
    public var groupId: String? {
        return internalUser.groupId
    }

    /// Attributes for the group.
    @objc
    public var groupAttributes: [String: Any]? {
        return internalUser.groupAttributes
    }

    /// The timezone of user if known.
    @objc
    public var timezone: String? {
        return internalUser.timezone
    }

    /// Not used on iOS.
    @objc
    public var gcm: [String]? {
        return internalUser.gcm
    }

    /// Array of apns tokens.
    @objc
    public var apns: [String]? {
        return internalUser.apns
    }

    /// Returns a new copy of user with userId replaced with aliasId.
    ///
    /// - Parameter aliasId: New id to replace userId.
    /// - Returns: A new copy of user with userId replaced with aliasId.
    @objc
    public func aliased(aliasId: String) -> ZCNUser {
        return ZCNUser(user: internalUser.aliased(aliasId: aliasId))
    }
}

