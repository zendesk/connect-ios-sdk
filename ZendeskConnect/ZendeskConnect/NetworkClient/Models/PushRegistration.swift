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

struct PushRegistration: Codable {
    var timestamp: Double?
    var userId: String
    var token: String?

    init(timestamp: Double?, userId: String, token: String?) {
        self.timestamp = timestamp
        self.userId = userId
        self.token = token
    }

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case userId = "user_id"
        case token
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(token, forKey: .token)
    }

    // Decodable protocol methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try container.decodeIfPresent(Double.self, forKey: .timestamp)
        userId = try container.decode(String.self, forKey: .userId)
        token = try container.decodeIfPresent(String.self, forKey: .token)
    }
}
