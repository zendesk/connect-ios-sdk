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


/// Used to create events.
public final class EventFactory: NSObject {


    /// Creates an event model with the specified data.
    ///
    /// - Parameters:
    ///   - properties: any extra information to send along with the event.
    ///   - event: An event with the specified data.
    public static func createEvent(event: String, properties: [String: Any]? = nil) -> Event {
        return Event(userId: nil, properties: properties, event: event)
    }
}

@objc
public final class ZCNEventFactory: NSObject {

    /// Creates an event model with the specified data.
    ///
    /// - Parameters:
    ///   - properties: any extra information to send along with the event.
    ///   - event: An event with the specified data.
    @objc
    public static func createEvent(event: String, properties: [String: Any]?) -> ZCNEvent {
        return ZCNEvent(event: EventFactory.createEvent(event: event, properties: properties))
    }
}
