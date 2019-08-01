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

/// Objective C wrapper for Swift Event model.
@objc(ZCNEvent)
public class ZCNEvent: NSObject {
    let internalEvent: Event
    
    /// Creates an event model with the specified data.
    ///
    /// - Parameters:
    ///   - event: An event with the specified data.
    init(event: Event) {
        internalEvent = event
    }
    public override var description: String {
        return internalEvent.event
    }
}
