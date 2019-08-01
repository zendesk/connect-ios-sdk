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

final class StoreIPMOperation: Operation {

    private let ipm: IPM
    private var storage: IPMSharedStorageModule
    private let center: UserNotificationCenterWrapper

    init(ipm: IPM, storage: IPMSharedStorageModule, center: UserNotificationCenterWrapper) {
        self.storage = storage
        self.ipm = ipm
        self.center = center
    }

    override func main() {
        guard isCancelled == false else {
            return
        }

        // Remove previous pending notifications.
        center.removePendingNotificationRequests(withIdentifiers: [storage.storedIdentifier])

        // Store the new info.
        storage.storedIPM = ipm
    }
}
