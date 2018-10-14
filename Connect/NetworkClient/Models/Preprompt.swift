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

        
struct PrePrompt: Codable {

    var title: String?
    var body: String?
    var noButton: String?
    var yesButton: String?

    init(title: String?, body: String?, noButton: String?, yesButton: String?) {
        self.title = title
        self.body = body
        self.noButton = noButton
        self.yesButton = yesButton
    }

    private enum CodingKeys: String, CodingKey { 
        case title = "title"
        case body = "body"
        case noButton = "no_button"
        case yesButton = "yes_button"
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(noButton, forKey: .noButton)
        try container.encodeIfPresent(yesButton, forKey: .yesButton)
    }

    // Decodable protocol methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        noButton = try container.decodeIfPresent(String.self, forKey: .noButton)
        yesButton = try container.decodeIfPresent(String.self, forKey: .yesButton)
    }
}

