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

/// Logger for Connect.
@objc
public final class ZCNLogger: NSObject {

    private override init() {}

    /// Enable or disable logging. Defaults to disabled.
    @objc
    public static var enabled: Bool {
        get {
            return Logger.enabled
        }
        set {
            Logger.enabled = newValue
        }
    }
}

/// Logger for Connect.
public enum Logger {
    
    /// Enable or disable logging. Defaults to disabled.
    public static var enabled: Bool = false
    
    /// Logs a message.
    ///
    /// - Parameter message: Message to be logged. Prepended with the string "[DEBUG]: "
    static func debug(_ message: String) {
        guard enabled else { return }
        print("[DEBUG]: \(message)")
    }
}
