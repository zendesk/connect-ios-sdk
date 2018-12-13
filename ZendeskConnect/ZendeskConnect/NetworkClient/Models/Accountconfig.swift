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

struct AccountConfig: Codable {
    var prompt: Bool?
    var promptEvent: String?
    var prePrompt: PrePrompt?

    init(prompt: Bool?, promptEvent: String?, prePrompt: PrePrompt?) {
        self.prompt = prompt
        self.promptEvent = promptEvent
        self.prePrompt = prePrompt
    }

    private enum CodingKeys: String, CodingKey {
        case prompt
        case promptEvent = "prompt_event"
        case prePrompt = "pre_prompt"
    }

    // Encodable protocol methods

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(prompt, forKey: .prompt)
        try container.encodeIfPresent(promptEvent, forKey: .promptEvent)
        try container.encodeIfPresent(prePrompt, forKey: .prePrompt)
    }

    // Decodable protocol methods

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prompt = try container.decodeIfPresent(Bool.self, forKey: .prompt)
        promptEvent = try container.decodeIfPresent(String.self, forKey: .promptEvent)
        prePrompt = try container.decodeIfPresent(PrePrompt.self, forKey: .prePrompt)
    }
}
