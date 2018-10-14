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


/// User model used to identify a user for tracking.
public struct User: Codable {

    var firstName: String?
    var lastName: String?
    var email: String?
    var attributes: [String: Any]?
    var userId: String
    var previousId: String?
    var phoneNumber: String?
    var groupId: String?
    var groupAttributes: [String: Any]?
    var timezone: String?
    var gcm: [String]?
    var apns: [String]?

    
    /// Creates a User with the details provided.
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
    public init(firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                attributes: [String: Any]? = nil,
                userId: String,
                previousId: String? = nil,
                phoneNumber: String? = nil,
                groupId: String? = nil,
                groupAttributes: [String: Any]? = nil,
                timezone: String? = nil,
                gcm: [String]? = nil,
                apns: [String]? = nil) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.attributes = attributes
        self.userId = userId
        self.previousId = previousId
        self.phoneNumber = phoneNumber
        self.groupId = groupId
        self.groupAttributes = groupAttributes
        self.timezone = timezone
        self.gcm = gcm
        self.apns = apns
    }

    private enum CodingKeys: String, CodingKey { 
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case attributes = "attributes"
        case userId = "user_id"
        case previousId = "previous_id"
        case phoneNumber = "phone_number"
        case groupId = "group_id"
        case groupAttributes = "group_attributes"
        case timezone = "timezone"
        case gcm = "gcm"
        case apns = "apns"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(attributes, forKey: .attributes)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(previousId, forKey: .previousId)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(groupId, forKey: .groupId)
        try container.encodeIfPresent(groupAttributes, forKey: .groupAttributes)
        try container.encodeIfPresent(timezone, forKey: .timezone)
        try container.encodeIfPresent(gcm, forKey: .gcm)
        try container.encodeIfPresent(apns, forKey: .apns)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        attributes = container.decodeIfPresent([String: Any].self, forKey: .attributes)
        userId = try container.decode(String.self, forKey: .userId)
        previousId = try container.decodeIfPresent(String.self, forKey: .previousId)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        groupId = try container.decodeIfPresent(String.self, forKey: .groupId)
        groupAttributes = container.decodeIfPresent([String: Any].self, forKey: .groupAttributes)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        gcm = try container.decodeIfPresent([String].self, forKey: .gcm)
        apns = try container.decodeIfPresent([String].self, forKey: .apns)
    }
}

extension User {
    
    static func createAnonymous() -> User {
        return User(userId: UUID().uuidString)
    }
    
    public static func alias(previousUser: User, newId: String) -> User {
        return User(firstName: previousUser.firstName,
                       lastName: previousUser.lastName,
                       email: previousUser.email,
                       attributes: previousUser.attributes,
                       userId: newId,
                       previousId: previousUser.userId,
                       phoneNumber: previousUser.phoneNumber,
                       groupId: previousUser.groupId,
                       groupAttributes: previousUser.groupAttributes,
                       timezone: previousUser.timezone,
                       gcm: previousUser.gcm,
                       apns: previousUser.apns)
    }
}

