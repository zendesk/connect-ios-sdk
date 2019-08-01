/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation

struct IPM: Codable {
    let instanceIdentifier: String
    let logo: URL?
    let heading: String
    let message: String
    let messageFontColor: String
    let headingFontColor: String
    let backgroundColor: String
    let buttonText: String
    let buttonBackgroundColor: String
    let buttonTextColor: String
    let action: URL?
    let timeToLive: TimeInterval

    private enum IPMError: String, LocalizedError {
        case timeToLive = "Time to live could not be parsed correctly."

        var errorDescription: String? {
            return self.rawValue
        }
    }

    private enum CodingKeys: String, CodingKey {
        case instanceIdentifier = "_oid"
        case logo
        case heading
        case message
        case messageFontColor
        case headingFontColor
        case backgroundColor
        case buttonText
        case buttonBackgroundColor
        case buttonTextColor
        case action
        case timeToLive = "ttl"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        instanceIdentifier = try values.decode(String.self, forKey: .instanceIdentifier)
        logo = try? values.decodeIfPresent(URL.self, forKey: .logo)
        heading = try values.decode(String.self, forKey: .heading)
        message = try values.decode(String.self, forKey: .message)
        messageFontColor = try values.decode(String.self, forKey: .messageFontColor)
        headingFontColor = try values.decode(String.self, forKey: .headingFontColor)
        backgroundColor = try values.decode(String.self, forKey: .backgroundColor)
        buttonText = try values.decode(String.self, forKey: .buttonText)
        buttonBackgroundColor = try values.decode(String.self, forKey: .buttonBackgroundColor)
        buttonTextColor = try values.decode(String.self, forKey: .buttonTextColor)
        action = try? values.decodeIfPresent(URL.self, forKey: .action)

        let timeToLiveString = try values.decode(String.self, forKey: .timeToLive)
        guard let timeToLive = TimeInterval(timeToLiveString) else {
            throw IPMError.timeToLive
        }
        self.timeToLive = timeToLive
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instanceIdentifier, forKey: .instanceIdentifier)
        try container.encodeIfPresent(logo, forKey: .logo)
        try container.encode(heading, forKey: .heading)
        try container.encode(message, forKey: .message)
        try container.encode(messageFontColor, forKey: .messageFontColor)
        try container.encode(headingFontColor, forKey: .headingFontColor)
        try container.encode(backgroundColor, forKey: .backgroundColor)
        try container.encode(buttonText, forKey: .buttonText)
        try container.encode(buttonBackgroundColor, forKey: .buttonBackgroundColor)
        try container.encode(buttonTextColor, forKey: .buttonTextColor)
        try container.encodeIfPresent(action, forKey: .action)
        try container.encode(String(timeToLive), forKey: .timeToLive)
    }
}
