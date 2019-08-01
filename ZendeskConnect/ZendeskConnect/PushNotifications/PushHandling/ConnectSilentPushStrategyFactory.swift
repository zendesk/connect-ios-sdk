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

protocol SilentPushStrategyFactory {
    init(coordinator: Coordinator)
    func create(userInfo: [AnyHashable: Any], connectAPI: ConnectAPI) -> SilentPushStrategy
}

final class ConnectSilentPushStrategyFactory: SilentPushStrategyFactory {
    private let coordinator: Coordinator

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    func create(userInfo: [AnyHashable: Any], connectAPI: ConnectAPI) -> SilentPushStrategy {
        if ConnectNotification.isUninstallTracker(userInfo: userInfo) {
            return UninstallSilentPushStrategy(userInfo: userInfo, connectAPI: connectAPI)
        }

        if ConnectNotification.isIPM(userInfo: userInfo) {
            return IPMSilentPushStrategy(userInfo: userInfo, connectAPI: connectAPI, coordinator: coordinator)
        }

        return DefaultSilentPushStrategy(userInfo: userInfo, connectAPI: connectAPI)
    }
}
