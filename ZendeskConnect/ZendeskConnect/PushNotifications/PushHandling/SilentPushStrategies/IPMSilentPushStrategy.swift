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

final class IPMSilentPushStrategy: SilentPushStrategy {
    private let userInfo: [AnyHashable : Any]
    private let connectAPI: ConnectAPI
    private let coordinator: Coordinator
    private let queue: OperationQueue

    init(userInfo: [AnyHashable: Any], connectAPI: ConnectAPI, coordinator: Coordinator) {
        self.userInfo = userInfo
        self.connectAPI = connectAPI
        self.coordinator = coordinator
        self.queue = OperationQueue()
        self.queue.maxConcurrentOperationCount = 1
        self.queue.qualityOfService = .userInteractive
    }

    func handleNotification(completion: @escaping SilentPushStrategyCompletion) {
        guard let ipm = decode(dictionary: userInfo, to: IPM.self) else {
            Logger.debug("This dictionary does not contain all IPM fields.")
            completion(true)
            return
        }

        let storage = Storage.shared.ipmModule
        let center = ConnectUserNotificationCenterWrapper(center: UNUserNotificationCenter.current())

        let imageResource = ImageResource(remoteURL: ipm.logo)
        let imageOperation = ImageOperation(imageResource: imageResource)
        let storeIPMOperation = StoreIPMOperation(ipm: ipm, storage: storage, center: center)
        let enqueueLocalNotification = EnqueueUserNotificationOperation(ipm: ipm, center: center)
        let applicationWaitOperation = ApplicationStateOperation(application: UIApplication.shared)
        let messagePresentationOperation = MessagePresentationOperation(imageResource: imageResource,
                                                                        coordinator: coordinator,
                                                                        storage: storage,
                                                                        center: center)
        messagePresentationOperation.addDependency(imageOperation)
        messagePresentationOperation.addDependency(storeIPMOperation)
        messagePresentationOperation.addDependency(applicationWaitOperation)
        messagePresentationOperation.addDependency(enqueueLocalNotification)
        imageOperation.addDependency(applicationWaitOperation)

        let backgroundOperations = [enqueueLocalNotification,
                                    imageOperation,
                                    storeIPMOperation]
        queue.addOperations(backgroundOperations, waitUntilFinished: false)

        let uiThreadOperations = [messagePresentationOperation, applicationWaitOperation]
        OperationQueue.main.addOperations(uiThreadOperations, waitUntilFinished: false)

        completion(true)
    }
}
