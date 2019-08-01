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

final class EnqueueUserNotificationOperation: Operation {

    private let ipm: IPM
    private let center: UserNotificationCenterWrapper

    init(ipm: IPM, center: UserNotificationCenterWrapper) {
        self.ipm = ipm
        self.center = center
    }

    override func main() {
        guard isCancelled == false, center.authorizationStatus == .authorized else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = ipm.heading
        content.body = ipm.message
        content.userInfo = ["_oid": ipm.instanceIdentifier, "_odl": ipm.action?.absoluteString ?? ""]
        content.sound = UNNotificationSound.default
        let triggerTime = max(1, ipm.timeToLive + 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: false)
        let request = UNNotificationRequest(identifier: ipm.instanceIdentifier, content: content, trigger: trigger)

        center.add(request) { _ in }
    }
}
