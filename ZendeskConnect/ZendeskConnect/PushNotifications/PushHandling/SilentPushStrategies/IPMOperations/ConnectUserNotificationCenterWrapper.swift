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
import UserNotifications

protocol UserNotificationCenterWrapper {
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    var authorizationStatus: UNAuthorizationStatus { get }
    func hasDelivered(oid: String) -> Bool 
}

final class ConnectUserNotificationCenterWrapper: UserNotificationCenterWrapper {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter) {
        self.center = center
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)? = nil) {
        center.add(request, withCompletionHandler: completionHandler)
    }

    func hasDelivered(oid: String) -> Bool {
        let group = DispatchGroup()
        group.enter()
        var oids: [String] = []
        center.getDeliveredNotifications(completionHandler: { delivered in
            oids.append(contentsOf: delivered.map { $0.request.identifier })
            group.leave()
        })
        group.wait()
        return oids.contains(oid)
    }

    var authorizationStatus: UNAuthorizationStatus {
        let group = DispatchGroup()
        var settings: UNAuthorizationStatus = .notDetermined
        group.enter()
        center.getNotificationSettings { (set) in
            settings = set.authorizationStatus
            group.leave()
        }
        group.wait()
        return settings
    }
}
