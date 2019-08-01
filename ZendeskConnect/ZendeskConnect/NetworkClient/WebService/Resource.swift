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

struct Empty: Codable {}

/// Resource is a model used to encapsulate the data required to make a HTTP request and handle JSON encoding and decoding.
struct Resource<A: Codable, R: Codable> {
    let url: URL
    let method: HttpMethod<Data>
    let parse: (Data, URLResponse?) -> Result<R>
}

extension Resource {
    /// Init
    ///
    /// - Parameters:
    ///   - url: Partial `URL` of the resource to which the request will be made for.
    ///   - method: `HttpMethod` being encoded/decoded.
    ///   - response: `Response` type.
    ///   - keyEncodingStrategy: `KeyEncodingStrategy`. Defaults to `convertToSnakeCase`.
    init(url: URL, method: HttpMethod<A> = .get, response: R.Type, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase) {
        self.url = url
        self.method = method.map { model in
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = keyEncodingStrategy
            return try! encoder.encode(model)
        }

        parse = { data, urlResponse in
            var parsingError: Error?
            let model: R?
            if response is Empty.Type {
                return Result.success(Empty(), urlResponse) as! Result<R>
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                model = try JSONDecoder().decode(R.self, from: data)
            } catch {
                model = nil
                parsingError = error
            }
            if let parsingError = parsingError {
                return Result<R>.failure(parsingError)
            }
            if let model = model {
                return Result<R>.success(model, urlResponse)
            }

            return Result<R>.failure(NSError(domain: "com.zendesk",
                                             code: 1111,
                                             userInfo: [NSLocalizedDescriptionKey: "Unknown error has occurred, model is nil but didn't fail parsing"]))
        }
    }
}
