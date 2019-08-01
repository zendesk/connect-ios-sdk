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

final class MessagePresentationOperation: Operation {

    private let coordinator: Coordinator
    private let imageResource: ImageResource
    private let storage: IPMSharedStorageModule
    private let center: UserNotificationCenterWrapper

    init(imageResource: ImageResource,
         coordinator: Coordinator,
         storage: IPMSharedStorageModule,
         center: UserNotificationCenterWrapper) {
        
        self.imageResource = imageResource
        self.coordinator = coordinator
        self.storage = storage
        self.center = center
    }

    override func main() {
        defer {
            storage.clearStorage()
        }

        guard isCancelled == false,
            let ipm = storage.storedIPM,
            center.hasDelivered(oid: ipm.instanceIdentifier) == false else {
                return
        }

        center.removePendingNotificationRequests(withIdentifiers: [storage.storedIdentifier])

        let viewModel = IPMViewModel(ipm: ipm, image: imageResource.image)
        self.coordinator.start(ipm: viewModel)
    }
}
