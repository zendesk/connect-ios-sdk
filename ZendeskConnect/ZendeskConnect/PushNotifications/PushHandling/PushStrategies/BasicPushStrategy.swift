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

final class BasicPushStrategy: PushStrategy {
    private let response: NotificationResponseWrapper
    private let connectAPI: ConnectAPI

    init(response: NotificationResponseWrapper, connectAPI: ConnectAPI) {
        self.response = response
        self.connectAPI = connectAPI
    }

    func handleNotification(completion: @escaping PushStrategyCompletion) {
        let userInfo = response.userInfo
        let metric = PushBasicMetric(_oid: ConnectNotification.instanceIDValue(userInfo: userInfo))
        connectAPI.send(received: metric, completion: nil)
        connectAPI.send(opened: metric, completion: nil)
        DeepLink.handleDeepLink(in: userInfo, with: UIApplication.shared) { _ in completion() }
    }
}

