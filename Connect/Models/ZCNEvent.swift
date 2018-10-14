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

@objc(ZCNEvent)
/// Objective C wrapper for swift Event model.
public class ZCNEvent: NSObject {
    let internalEvent: Event
    
    
    /// Creates a track model with the specified data.
    ///
    /// - Parameters:
    ///   - userId: User id to associate this event with.
    ///   - properties: any extra information to send along with the event.
    ///   - event: An event with the specified data.
    @objc public init(userId: String,
                      properties: [String: Any]?,
                      event: String) {
        
        internalEvent = Event(userId: userId,
                              properties: properties,
                              event: event)
    }
    
    public override var description: String {
        return internalEvent.event
    }
}
