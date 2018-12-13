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

struct UninstallTracker: Codable {
    var i: String?
    var revoked: Bool?

    init(i: String?, revoked: Bool?) {
        self.i = i
        self.revoked = revoked
    }

    private enum CodingKeys: String, CodingKey {
        case i
        case revoked
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(i, forKey: .i)
        try container.encodeIfPresent(revoked, forKey: .revoked)
    }

    // Decodable protocol methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        i = try container.decodeIfPresent(String.self, forKey: .i)
        revoked = try container.decodeIfPresent(Bool.self, forKey: .revoked)
    }
}
