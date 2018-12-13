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

/// Model for event tracking API.
public struct Event: Codable {

    public let userId: String?
    public let timestamp: TimeInterval
    public let properties: [String: Any]?
    public let event: String

    
    /// Creates an event model with the specified data.
    ///
    /// - Parameters:
    ///   - userId: User id to associate this event with.
    ///   - timestamp: timestamp for the event.
    ///   - properties: any extra information to send along with the event.
    ///   - event: An event with the specified data.
    init(userId: String?, timestamp: TimeInterval = Date().timeIntervalSince1970, properties: [String: Any]?, event: String) {
        self.userId = userId
        self.timestamp = timestamp
        self.properties = properties
        self.event = event
    }

    private enum CodingKeys: String, CodingKey { 
        case userId = "user_id"
        case timestamp = "timestamp"
        case properties = "properties"
        case event = "event"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(properties, forKey: .properties)
        try container.encode(event, forKey: .event)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        timestamp = try container.decode(TimeInterval.self, forKey: .timestamp)
        properties = container.decodeIfPresent([String: Any].self, forKey: .properties)
        event = try container.decode(String.self, forKey: .event)
    }
}
