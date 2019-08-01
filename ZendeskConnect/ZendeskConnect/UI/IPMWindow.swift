/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import UIKit

final class IPMWindow: UIWindow {
    private static var window: IPMWindow?

    static var shared: IPMWindow {
        guard let window = window else {
            let window = IPMWindow(frame: UIScreen.main.bounds)
            window.windowLevel = .statusBar

            let rootViewController = UIViewController(nibName: nil, bundle: nil)
            window.rootViewController = rootViewController
            self.window = window
            return window
        }
        return window
    }

    static func resignKeyAndHide() {
        shared.isHidden = true
        shared.resignKey()
    }
}
