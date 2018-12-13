/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation
import UserNotifications

let ConnectVersionString = "2.0.0"

fileprivate let ConnectInitLogMessage = "Connect is not initialised. Call the init with environment before using other methods."

extension DispatchWallTime {
    static func seconds(_ n: Int) -> DispatchWallTime {
        return .now() + DispatchTimeInterval.seconds(n)
    }
}

// This Connect class is essentially a wrapper for the Connect shaddow class.
// The intention is to have a singleton with a public interface that calls through
// to interfaces on the connect shadow.


/// Connect
@objc(ZCNConnect)
public final class Connect: NSObject {

    /// Shared Connect instance.
    @objc
    public static let instance = Connect()
    private override init() {}

    /// Internal connect shadow. Contains the actual business logic.
    private var connectShadow: ConnectShadow?


    /// The user which was last identified. Or if no
    /// call to idnetify has been made, an anonymous user.
    ///
    /// - Returns: The current user being tracked.
    public var user: User? {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return nil
        }
        return connectShadow.user
    }

    /// The user which was last identified. Or if no
    /// call to idnetify has been made, an anonymous user.
    ///
    /// - This is an Objective-C wrapper for the swift interface.
    ///
    /// - Returns: The current user being tracked.
    @objc
    public func currentUser() -> ZCNUser? {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return nil
        }
        return ZCNUser(user: connectShadow.user)
    }


    /// Initialise Connect with your private key.
    ///
    /// - Parameter privateKey: development or production private key.
    /// - Returns: Returns the shared instance configured with the private key.
    @objc
    @discardableResult
    public func `init`(privateKey: String) -> Connect {
        connectShadow = ConnectShadowFactory.createConnectShadow(privateKey: privateKey,
                                                                 userStorageType: UserStorage.self,
                                                                 configStorageType: ConfigStorage.self,
                                                                 environmentStorableType: EnvironmentStorage.self,
                                                                 currentInstance: connectShadow)
        return Connect.instance
    }


    /// Logout when you want to stop tracking events for a user.
    /// You need to logout a user before identifying a new user, otherwise
    /// the new user will be aliased with the previous user.
    @objc
    public func logoutUser() {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.logoutUser()
    }

    /// You identify a user with Connect each time you create
    /// a new user or update an existing user in your system.
    ///
    /// It is recommended that you send as much information
    /// about the user as possible. Any attribute you send can be used in
    /// the messages from Connect.
    ///
    /// - This is an Objective-C wrapper for the swift interface.
    ///
    /// - Parameter user: a user to identify
    @objc
    public func identifyUser(_ user: ZCNUser) {
        identifyUser(user.internalUser)
    }


    /// You identify a user with Connect each time you create
    /// a new user or update an existing user in your system.
    ///
    /// It is recommended that you send as much information
    /// about the user as possible. Any attribute you send can be used in
    /// the messages from Connect.
    ///
    /// - Parameter user: a user to identify
    public func identifyUser(_ user: User) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.identifyUser(user)
    }

    /// You can track unlimited events using the Connect API. Any event you send
    /// can be used as a trigger event for a message or the goal event of a desired
    /// user flow which triggers a message when not completed within a set period of time.
    ///
    /// - This is an Objective-C wrapper for the swift interface.
    ///
    /// - Parameter event: an event to send to the Connect API.
    @objc
    public func trackEvent(_ event: ZCNEvent) {
        trackEvent(event.internalEvent)
    }

    /// You can track unlimited events using the Connect API. Any event you send
    /// can be used as a trigger event for a message or the goal event of a desired
    /// user flow which triggers a message when not completed within a set period of time.
    ///
    /// - Parameter event: an event to send to the Connect API.
    public func trackEvent(_ event: Event) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.trackEvent(event)
    }

    /// If you want your app to send push notifications, you can register the device token
    /// for the user independently of an identify call.
    ///
    /// - Parameter token: The Data token obtained from `UIApplicationDelegate`'s method.
    @objc
    public func registerPushToken(_ token: Data) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.registerPushToken(token)
    }


    /// Disable the device's push token to tell Connect not to send notifications to this device.
    ///
    /// - Parameter token: push token data.
    @objc
    public func disablePushToken() {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.disablePushToken()
    }

    /// Takes an userInfo dictionary from a remote notification and returns
    /// true if it's a Connect push notification.
    ///
    /// - Parameter userInfo: should come from a remote notification.
    /// - Returns: true if it's a Connect push, false otherwise.
    @objc
    public func isConnectNotification(userInfo: [AnyHashable: Any]) -> Bool {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return false
        }
        return connectShadow.pushHandler.isConnectNotification(userInfo: userInfo)
    }

    /// Takes a user notification center response and returns
    /// true if it's a response from a Connect uninstall tracker notification.
    ///
    /// - Parameter response: should come from a remote notification.
    /// - Returns: true if it's a Connect uninstall tracker, false otherwise.
    @available(iOS 10.0, *)
    @objc
    public func isConnectNotificationResponse(_ response: UNNotificationResponse) -> Bool {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return false
        }
        return connectShadow.pushHandler.isConnectNotification(userInfo: response.notification.request.content.userInfo)
    }

    /// Takes an userInfo dictionary from a remote notification and returns
    /// true if it's a Connect uninstall tracker notification.
    ///
    /// - Parameter userInfo: should come from a remote notification.
    /// - Returns: true if it's a Connect uninstall tracker, false otherwise.
    @objc
    public func isUninstallTracker(userInfo: [AnyHashable: Any]) -> Bool {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return false
        }
        return connectShadow.pushHandler.isUninstallTracker(userInfo: userInfo)
    }

    /// Handle push from user notification center did received notification response delegate method.
    ///
    /// - Parameters:
    ///   - response: the users response to the notification.
    ///   - completion: block to call when processing is finished.
    @available(iOS 10.0, *)
    @objc
    public func handleNotificationResponse(_ response: UNNotificationResponse, completion: @escaping () -> Void) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.pushHandler.handleNotification(response: response, completion: completion)
    }

    /// Handle push from did receive remote notification.
    ///
    /// - Parameters:
    ///   - userInfo: info dict from the push notification
    ///   - completion: completion handler.
    @objc
    public func handleNotification(userInfo: [AnyHashable: Any], completion: @escaping (Bool) -> Void) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.pushHandler.handleNotification(userInfo: userInfo, configuration: connectShadow.configuration, completion: completion)
    }
}
