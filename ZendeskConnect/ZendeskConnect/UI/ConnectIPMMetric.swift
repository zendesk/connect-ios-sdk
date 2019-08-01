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

protocol IPMMetric {
    func presented()
    func actionPressed()
    func dismissed()
}

final class ConnectIPMMetric: NSObject, IPMMetric {
    private var ipmOid: String
    private var connectAPI: ConnectAPI

    func presented() {
        let metric = PushBasicMetric(_oid: ipmOid)
        connectAPI.send(received: metric, completion: nil)
        connectAPI.send(opened: metric, completion: nil)
    }

    func actionPressed() {
        let event = EventFactory.createEvent(event: "ipm_metric_action_tapped")
        connectAPI.track(event)
    }

    func dismissed() {
        let event = EventFactory.createEvent(event: "ipm_metric_dismissed")
        connectAPI.track(event)
    }

    init(connectAPI: ConnectAPI, ipmOid: String) {
        self.connectAPI = connectAPI
        self.ipmOid = ipmOid
        super.init()
    }
}
