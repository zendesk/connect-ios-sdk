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

final class IPMCoordinator: NSObject, Coordinator {
    private let connectAPI: ConnectAPI
    private let window: IPMWindow
    private var metric = PushBasicMetric(_oid: nil)

    private var transitionDelegate: CustomTransitionDelegate?
    private weak var ipmViewController: IPMViewController?

    init(connectAPI: ConnectAPI, window: IPMWindow = IPMWindow.shared) {
        self.connectAPI = connectAPI
        self.window = window
    }

    func start(ipm: IPMViewModel) {
        metric = PushBasicMetric(_oid: ipm.oid)

        guard ipmViewController == nil else {
            Logger.debug("Currently displaying, crowding out incoming IPM.")
            return
        }

        transitionDelegate = CustomTransitionDelegate()

        let ipmMetric = ConnectIPMMetric(connectAPI: connectAPI, ipmOid: ipm.oid)

        let viewController = IPMViewController(ipm: ipm, ipmMetric: ipmMetric)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self.transitionDelegate

        window.makeKeyAndVisible()
        window.rootViewController?.present(viewController, animated: true, completion: nil)

        ipmViewController = viewController
    }
}
