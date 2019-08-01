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

/// Responsible for inspecting a push notification dictionary.
enum ConnectNotification {

    /// These are the keys which Connect puts in its push notification payloads.
    private enum Keys {
        /// Ghost push.
        static let ghostPush = "_ogp"

        /// Instance id.
        static let id = "_oid"

        /// Test message.
        static let testMessage = "_otm"

        /// Quiet push.
        static let quietPush = "_oq"

        /// Deep link.
        static let deepLink = "_odl"

        /// Push type.
        static let type = "type"

        /// URL for the logo in the payload.
        static let logo = "logo"
    }

    /// These are values which are associated with the Keys.
    private enum Values {
        /// Can be a value of the push type field.
        static let ipm = "ipm"
    }


    /// Takes a userInfo dictionary from a remote notification and returns
    /// `true` if it's a Connect push notification.
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: `true` if it's a Connect push, `false` otherwise.
    static func isConnectNotification(userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo[Keys.id] != nil
    }

    /// Takes a userInfo dictionary from a remote notification and returns
    /// `true` if it's a push notification for the host app.
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: `true` if it's a host app push, `false` otherwise.
    static func isHostAppNotification(userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo[Keys.id] == nil
    }


    /// Takes a userInfo dictionary from a remote notification and returns
    /// `true` if its type is an "ipm".
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: `true` if its type is equal to "ipm", `false` otherwise.
    static func isIPM(userInfo: [AnyHashable: Any]) -> Bool {
        let ipm = userInfo[Keys.type] as? String
        return ipm == Values.ipm
    }


    /// Takes a userInfo dictionary from a remote notification and returns
    /// `true` if it's a Connect uninstall tracker notification.
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: `true` if it's a Connect uninstall tracker, `false` otherwise.
    static func isUninstallTracker(userInfo: [AnyHashable: Any]) -> Bool {
        let tracker = userInfo[Keys.ghostPush] as? Bool
        return tracker == true
    }


    /// Takes a userInfo dictionary from a remote notification and returns
    /// `true` if it's a Connect quiet push notification.
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: `true` if it's a silent push, `false` otherwise.
    static func isQuietPush(userInfo: [AnyHashable: Any]) -> Bool {
        let quietPush = userInfo[Keys.quietPush] as? Bool
        return quietPush == true
    }


    /// Takes a userInfo dictionary from a remote notification and returns
    /// the value for the instance ID key (_oid).
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: The value for the instance ID key.
    static func instanceIDValue(userInfo: [AnyHashable: Any]) -> String? {
        return userInfo[Keys.id] as? String
    }

    static func isDeepLink(userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo[Keys.deepLink] != nil
    }

    /// Takes a userInfo dictionary from a remote notification and returns
    /// the value for the deep link key (_odl).
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: The value for the deep link key.
    static func deepLinkValue(userInfo: [AnyHashable: Any]) -> String? {
        return userInfo[Keys.deepLink] as? String
    }

    /// Takes a userInfo dictionary from a remote notification and returns
    /// the `URL` value for the logo key.
    ///
    /// - Parameter userInfo: Should come from a remote notification.
    /// - Returns: The `URL` value for the logo key.
    static func logoURL(userInfo: [AnyHashable: Any]) -> URL? {
        return userInfo[Keys.logo] as? URL
    }
}
