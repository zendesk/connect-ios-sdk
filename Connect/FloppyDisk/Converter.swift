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

struct DefaultConverter: Converter {
    init() {}
}

protocol Converter {
    func from<T: Codable>(_ data: Data) throws -> T
    func toData<T: Codable>(_ value: T) throws -> Data
}

extension Converter {
    func from<T>(_ data: Data) throws -> T where T : Decodable, T : Encodable {
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func toData<T>(_ value: T) throws -> Data where T : Decodable, T : Encodable {
        return try JSONEncoder().encode(value)
    }
}

