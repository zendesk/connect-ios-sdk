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

protocol DeepLinkHandler {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
    func canOpenURL(_ url: URL) -> Bool
}

final class DeepLink {
    /// Handles a deep link contained in a Connect push notification.
    static func handleDeepLink(in userInfo: [AnyHashable: Any],
                        with deepLinkHandler: DeepLinkHandler,
                        completionHandler completion: ((Bool) -> Void)? = nil) {

        guard
            let deepLink = ConnectNotification.deepLinkValue(userInfo: userInfo),
            let deepLinkURL = URL(string: deepLink) else {
                Logger.debug("No deep link found.")
                return
        }

        guard deepLinkHandler.canOpenURL(deepLinkURL) else {
            Logger.debug("App is unable to open deep link url: \(deepLinkURL)")
            return
        }

        Logger.debug("Handling push as deep link.")
        deepLinkHandler.open(deepLinkURL, options: [:], completionHandler: completion)
    }
}
