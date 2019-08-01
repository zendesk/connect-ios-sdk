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

let ConnectVersionString = "2.0.1"

fileprivate let ConnectInitLogMessage = "Connect is not initialised. Call the init with environment before using other methods."

extension DispatchWallTime {
    static func seconds(_ n: Int) -> DispatchWallTime {
        return .now() + DispatchTimeInterval.seconds(n)
    }
}

// This Connect class is essentially a wrapper for the ConnectShadow class.
// The intention is to have a singleton with a public interface that calls through
// to interfaces on ConnectShadow.

/// Connect
@objc(ZCNConnect)
public final class Connect: NSObject {

    /// Shared `Connect` instance.
    @objc
    public static let instance = Connect()
    private override init() {}

    /// Internal `ConnectShadow`. Contains the actual business logic.
    private var connectShadow: ConnectShadow?


    /// The `User` which was last identified. Or if no
    /// call to identify has been made, an anonymous user.
    ///
    /// - Returns: The current `User` being tracked.
    public var user: User? {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return nil
        }
        return connectShadow.user
    }

    /// The `User` which was last identified. Or if no
    /// call to identify has been made, an anonymous user.
    ///
    /// - This is an Objective-C wrapper for the Swift interface.
    ///
    /// - Returns: The current `User` being tracked.
    @objc
    public func currentUser() -> ZCNUser? {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return nil
        }
        return ZCNUser(user: connectShadow.user)
    }


    /// Initialize `Connect` with your private key.
    ///
    /// - Parameter privateKey: Development or production private key.
    /// - Returns: Returns the shared `instance` configured with the private key.
    @objc
    @discardableResult
    public func initialize(privateKey: String) -> Connect {
        connectShadow = ConnectShadowFactory.createConnectShadow(privateKey: privateKey,
                                                                 userStorageType: UserStorage.self,
                                                                 configStorageType: ConfigStorage.self,
                                                                 environmentStorableType: EnvironmentStorage.self,
                                                                 silentPushStrategyFactoryType: ConnectSilentPushStrategyFactory.self,
                                                                 currentInstance: connectShadow)
        return Connect.instance
    }

    /// Logout when you want to stop tracking events for a `User`.
    /// You need to logout a `User` before identifying a new `User`, otherwise
    /// the new `User` will be aliased with the previous `User`.
    @objc
    public func logoutUser() {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.logoutUser()
    }

    /// You identify a `User` with `Connect` each time you create
    /// a new `User` or update an existing `User` in your system.
    ///
    /// It is recommended that you send as much information
    /// about the `User` as possible. Any attribute you send can be used in
    /// the messages from `Connect`.
    ///
    /// - This is an Objective-C wrapper for the Swift interface.
    ///
    /// - Parameter user: A `User` to identify.
    @objc
    public func identifyUser(_ user: ZCNUser) {
        identifyUser(user.internalUser)
    }


    /// You identify a `User` with `Connect` each time you create
    /// a new `User` or update an existing `User` in your system.
    ///
    /// It is recommended that you send as much information
    /// about the `User` as possible. Any attribute you send can be used in
    /// the messages from `Connect`.
    ///
    /// - Parameter user: A `User` to identify.
    public func identifyUser(_ user: User) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.identifyUser(user)
    }

    /// You can track unlimited events using the `Connect` API. Any event you send
    /// can be used as a trigger event for a message, or the goal event of a desired
    /// user flow, which triggers a message when not completed within a set period of time.
    ///
    /// - This is an Objective-C wrapper for the Swift interface.
    ///
    /// - Parameter event: An `Event` to send to the `Connect` API.
    @objc
    public func trackEvent(_ event: ZCNEvent) {
        trackEvent(event.internalEvent)
    }

    /// You can track unlimited events using the `Connect` API. Any event you send
    /// can be used as a trigger event for a message, or the goal event of a desired
    /// user flow, which triggers a message when not completed within a set period of time.
    ///
    /// - Parameter event: An `Event` to send to the `Connect` API.
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
    /// - Parameter token: The `Data` token obtained from `UIApplicationDelegate`'s method.
    @objc
    public func registerPushToken(_ token: Data) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.registerPushToken(token)
    }


    /// Disable the device's push token to tell `Connect` not to send notifications to this device.
    @objc
    public func disablePushToken() {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.disablePushToken()
    }

    /// Takes an userInfo dictionary from a remote notification and returns
    /// `true` if it's a `Connect` push notification.
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: `true` if it's a Connect push, `false` otherwise.
    @objc
    public func isConnectNotification(userInfo: [AnyHashable: Any]) -> Bool {
        guard connectShadow != nil else {
            Logger.debug(ConnectInitLogMessage)
            return false
        }
        return ConnectNotification.isConnectNotification(userInfo: userInfo)
    }

    /// Takes a `userNotificationCenter` response and returns
    /// `true` if it's a response from a `Connect` uninstall tracker notification.
    ///
    /// - Parameter response: Should come from a remote notification.
    /// - Returns: `true` if it's a `Connect` uninstall tracker, `false` otherwise.
    @objc
    public func isConnectNotificationResponse(_ response: UNNotificationResponse) -> Bool {
        guard connectShadow != nil else {
            Logger.debug(ConnectInitLogMessage)
            return false
        }
        return ConnectNotification.isConnectNotification(userInfo: response.notification.request.content.userInfo)
    }

    /// Handle push from `userNotificationCenter didReceive UNNotificationResponse` delegate method.
    ///
    /// - Parameters:
    ///   - response: The user's response to the notification.
    ///   - completion: Block to call when processing is finished.
    @objc
    public func handleNotificationResponse(_ response: UNNotificationResponse, completion: @escaping () -> Void) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        let responseWrapper = ConnectNotificationResponse(response: response)
        connectShadow.handleNotificationResponse(responseWrapper, completion: completion)
    }

    /// Handle push from `didReceiveRemoteNotification`.
    ///
    /// - Parameters:
    ///   - userInfo: Dictionary from the push notification.
    ///   - completion: Completion handler.
    @objc
    public func handleNotification(userInfo: [AnyHashable: Any], completion: @escaping (Bool) -> Void) {
        guard let connectShadow = connectShadow else {
            Logger.debug(ConnectInitLogMessage)
            return
        }
        connectShadow.handleNotification(userInfo: userInfo, completion: completion)
    }
}
