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

struct PairDevice: Codable {
    var code: Int
    var deviceToken: String
    var deviceName: String

    init(code: Int, deviceToken: String, deviceName: String) {
        self.code = code
        self.deviceToken = deviceToken
        self.deviceName = deviceName
    }

    private enum CodingKeys: String, CodingKey {
        case code
        case deviceToken
        case deviceName
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(deviceToken, forKey: .deviceToken)
        try container.encode(deviceName, forKey: .deviceName)
    }

    // Decodable protocol methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        deviceToken = try container.decode(String.self, forKey: .deviceToken)
        deviceName = try container.decode(String.self, forKey: .deviceName)
    }
}
