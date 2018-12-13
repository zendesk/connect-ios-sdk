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

/// EventResource is a simple struct to provide a simplified way to construct Resource instances
struct EventResource {
    
    static func track(body: Event) -> Resource<Event, Empty> {
        let url = URL(string: "/v2/track")!
        return Resource(url: url, method: .post(body), response: Empty.self)
    }
    
    
    static func trackBatch(body: [Event]) -> Resource<[Event], Empty> {
        let url = URL(string: "/v2/track/batch")!
        return Resource(url: url, method: .post(body), response: Empty.self)
    }
    
}
