/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import UserNotifications
import UIKit


protocol DeepLinkHandler {
    @available(iOS 10, *)
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
    @discardableResult func openURL(_ url: URL) -> Bool
    func canOpenURL(_ url: URL) -> Bool
}

extension UIApplication: DeepLinkHandler {}


/// Short wrapper on DispatchQueue.main.async {}
///
/// - Parameter onMain: something that should be called on the main thread.
func onMain(_ onMain: @escaping ()-> Void) {
    DispatchQueue.main.async {
        onMain()
    }
}


/// Contains the logic for handling and responding to
/// Connect push notifications.
final class ConnectPushNotificationHandler {


    /// api client used to send push metrics.
    private let connectClient: ConnectAPI

    /// Create a ConnectPushNotificationHandler.
    ///
    /// - Parameter connectClient: api client used to send push metrics.
    init(connectClient: ConnectAPI) {
        self.connectClient = connectClient
    }


    /// These are the keys which Connect puts in it's push notification payloads.
    private enum NotificationKeys {
        /// Ghost push.
        static let ghostPush = "_ogp"

        /// Notification id.
        static let id = "_oid"

        /// Test message.
        static let testMessage = "_otm"

        /// Quiet push.
        static let quietPush = "_oq"

        /// Deep link.
        static let deepLink = "_odl"
    }


    /// Takes an userInfo dictionary from a remote notification and returns
    /// true if it's a Connect push notification.
    ///
    /// - Parameter userInfo: should come from a remote notification.
    /// - Returns: true if it's a Connect push, false otherwise.
    func isConnectNotification(userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo[NotificationKeys.id] != nil
    }


    /// Takes an userInfo dictionary from a remote notification and returns
    /// true if it's a Connect uninstall tracker notification.
    ///
    /// - Parameter userInfo: should come from a remote notification.
    /// - Returns: true if it's a Connect uninstall tracker, false otherwise.
    func isUninstallTracker(userInfo: [AnyHashable: Any]) -> Bool {
        guard let tracker = userInfo[NotificationKeys.ghostPush] as? Bool else {
            return false
        }
        return tracker
    }


    /// Takes an userInfo dictionary from a remote notification and returns
    /// true if it's a Connect uninstall tracker notification.
    ///
    /// - Parameter userInfo: should come from a remote notification.
    /// - Returns: true if it's a silent push, false otherwise.
    func isSilentPush(userInfo: [AnyHashable: Any]) -> Bool {
        guard let silentPush = userInfo[NotificationKeys.quietPush] as? Bool else {
            return false
        }
        return silentPush
    }


    /// Get push authorization.
    ///
    /// The UNUserNotificationCenter settings completion block can be called
    /// on a background thread. So the block passed into this method is
    /// called on the main thread.
    ///
    /// - Parameter completion: Block with a Bool parameter. true if notifications are authorised.
    @available(iOS 10.0, *)
    private func getPushAuth(completion: @escaping (Bool) -> Void) {
        // The settings completion block may be executed on a background thread.
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            onMain { completion(settings.authorizationStatus == .authorized) }
        }
    }


    /// Handle push from did receive remote notification.
    ///
    /// - Parameters:
    ///   - userInfo: info dict from the push notification
    ///   - configuration: the current configuration for Connect.
    ///   - completion: completion handler.
    func handleNotification(userInfo: [AnyHashable: Any],
                            configuration: Config,
                            completion: @escaping (Bool) -> Void) {

        guard isConnectNotification(userInfo: userInfo) else {
            Logger.debug("Won't handle remote notification as it is not from Connect.")
            completion(false)
            return
        }

        guard configuration.enabled else {
            Logger.debug("The SDK is disabled due to remote kill.")
            completion(false)
            return
        }

        // Use separate logic for iOS 10 and above.
        if #available(iOS 10.0, *) {
            received(iOS10: userInfo, completion: completion)
        } else {
            received(iOS9: userInfo, completion: completion)
        }
    }


    /// iOS 9 push handling.
    ///
    /// - Parameters:
    ///   - userInfo: info dict from the push notification
    ///   - completion: completion handler.
    private func received(iOS9 userInfo: [AnyHashable: Any], completion: @escaping (Bool) -> Void) {

        guard let settings = UIApplication.shared.currentUserNotificationSettings else {
            Logger.debug("Can't get push settings. Won't handle push.")
            return
        }

        let app = UIApplication.shared
        let authorised = app.isRegisteredForRemoteNotifications && settings.types.isEmpty == false

        // If this is an uninstall tracker
        // acknowledge with current authorization,
        // the return.
        guard isUninstallTracker(userInfo: userInfo) == false else {
            Logger.debug("Handling push as an uninstall tracker.")
            let tracker = UninstallTracker(i: userInfo[NotificationKeys.id] as? String, revoked: authorised == false)
            connectClient.track(uninstall: tracker, completion: completion)
            return
        }

        // From here on in we'll send a push metric
        // to say that we've either received or opened a push.
        let metric = PushBasicMetric(_oid: userInfo[NotificationKeys.id] as? String)
        connectClient.send(received: metric, completion: completion)

        // Currently we do nothing for a silent push.
        // An integrator can optionally decide to act on this
        // outside of the SDK.
        guard isSilentPush(userInfo: userInfo) == false else {
            Logger.debug("Silent push received. Won't handle.")
            return
        }

        // Not autherised.
        // Do nothing.
        guard authorised else {
            Logger.debug("Not handling push. Notifications are disabled.")
            completion(false)
            return
        }

        switch UIApplication.shared.applicationState {
        case .inactive: // attempt deeplink, send opened metric
            handleDeepLink(in: userInfo, with: app)
            connectClient.send(opened: metric, completion: completion)
        case .active: // app is in foreground, show alert and send metrics.
            guard let alert = UIAlertController.create(
                withUserInfo: userInfo,
                cancelAction: {_ in
                    self.connectClient.send(received: metric, completion: completion)
            },
                confirmAction:  { _ in
                    self.handleDeepLink(in: userInfo, with: app)
                    self.connectClient.send(opened: metric, completion: completion)
            }) else {
                Logger.debug("Received push, but could not read aps payload.")
                return
            }

            alert.show()
        case .background:
            break
        }
    }


    /// iOS 10 push handling.
    ///
    /// - Parameters:
    ///   - userInfo: info dict from the push notification
    ///   - completion: completion handler.
    @available(iOS 10.0, *)
    private func received(iOS10 userInfo: [AnyHashable: Any], completion: @escaping (Bool) -> Void) {

        getPushAuth { authorised in

            // If this is an uninstall tracker
            // acknowledge with current authorization,
            // the return.
            guard self.isUninstallTracker(userInfo: userInfo) == false else {
                Logger.debug("Handling push as an uninstall tracker.")
                let tracker = UninstallTracker(i: userInfo[NotificationKeys.id] as? String, revoked: authorised == false)
                self.connectClient.track(uninstall: tracker, completion: completion)
                return
            }

            let metric = PushBasicMetric(_oid: userInfo[NotificationKeys.id] as? String)
            self.connectClient.send(received: metric, completion: completion)
        }
    }


    /// Handle push from user notification center did received notification response delegate method.
    ///
    /// - Parameters:
    ///   - response: the users response to the notification.
    ///   - completion: block to call when processing is finished.
    @available(iOS 10.0, *)
    func handleNotification(response: UNNotificationResponse, completion: @escaping () -> Void) {
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            return
        }

        let userInfo = response.notification.request.content.userInfo

        guard isConnectNotification(userInfo: userInfo) else {
            Logger.debug("Won't handle remote notification as it is not from Connect.")
            completion()
            return
        }

        let metric = PushBasicMetric(_oid: userInfo[NotificationKeys.id] as? String)
        connectClient.send(opened: metric, completion: nil)

        handleDeepLink(in: userInfo, with: UIApplication.shared) { _ in completion() }
    }


    /// Handles a deep link contained in a Connect push notificaiton.
    ///
    /// - Parameters:
    ///   - response: the users response to the notification.
    ///   - completion: block to call when finished.
    func handleDeepLink(in userInfo: [AnyHashable: Any],
                        with deepLinkHandler: DeepLinkHandler,
                        completionHandler completion: ((Bool) -> Void)? = nil) {

        guard
            let deepLink = userInfo[NotificationKeys.deepLink] as? String,
            let deepLinkURL = URL(string: deepLink) else {
                Logger.debug("No deep link found.")
                return
        }

        guard deepLinkHandler.canOpenURL(deepLinkURL) else {
            Logger.debug("App is unable to open deeplink url: \(deepLinkURL)")
            return
        }

        Logger.debug("Handling push as deeplink.")
        if #available(iOS 10.0, *) {
            deepLinkHandler.open(deepLinkURL, options: [:], completionHandler: completion)
        } else {
            deepLinkHandler.openURL(deepLinkURL)
        }
    }
}
