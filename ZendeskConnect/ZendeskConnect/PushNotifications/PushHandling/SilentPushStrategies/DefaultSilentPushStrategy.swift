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

final class DefaultSilentPushStrategy: SilentPushStrategy {
    private let userInfo: [AnyHashable : Any]
    private let connectAPI: ConnectAPI

    init(userInfo: [AnyHashable : Any], connectAPI: ConnectAPI) {
        self.userInfo = userInfo
        self.connectAPI = connectAPI
    }

    func handleNotification(completion: @escaping SilentPushStrategyCompletion) {
        let oid = ConnectNotification.instanceIDValue(userInfo: userInfo)
        let metric = PushBasicMetric(_oid: oid)
        connectAPI.send(received: metric, completion: completion)
    }
}
