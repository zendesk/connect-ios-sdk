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

    /// First name of user if known.
    public let firstName: String?

    /// Last name of user if known.
    public let lastName: String?

    /// Email of user if known.
    public let email: String?

    /// Any attributes to associate with the user.
    public let attributes: [String: Any]?

    /// An id for the user to be sent with track events.
    public let userId: String

    /// Used when aliasing a user. This will generally be the value that was last used in userId.
    public let previousId: String?

    /// Phone number of user if known.
    public let phoneNumber: String?

    /// Grouping this user by id.
    public let groupId: String?

    /// Attributes for the group.
    public let groupAttributes: [String: Any]?

    /// The timezone of user if known.
    public let timezone: String?
    
    /// Not used on iOS.
    public let gcm: [String]?

    /// Array of apns tokens.
    public let apns: [String]?

    
    /// Creates a User with the details provided.
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
    ///   - gcm: Not used in iOS.
    ///   - apns: Array of apns tokens.
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

