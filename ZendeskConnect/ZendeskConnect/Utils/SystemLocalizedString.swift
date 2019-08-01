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


/// Use the system localized strings.
enum SystemLocalizedString {

    /// Returns a localized string for OK.
    static var ok: String {
        return string(for: "OK")
    }

    /// Returns a localized string for Cancel.
    static var cancel: String {
        return string(for: "Cancel")
    }


    /// Gets `UIKit Bundle` and reads the localized string for the key provided.
    ///
    /// - Parameters:
    ///   - key: The key for a `String` in the table identified by tableName.
    ///   - value: The value to return if key is `nil` or if a localized string for key can’t be found in the table.
    ///   - table: The receiver’s `String` table to search. If tableName is `nil` or is an empty `String`,
    ///            the method attempts to use the table in `Localizable.strings`.
    /// - Returns: A localized version of the `String` designated by key in table tableName.
    private static func string(for key: String, default value: String? = nil, table: String? = nil) -> String {
        guard let bundle = Bundle(identifier: "com.apple.UIKit") else {
            return key
        }
        return bundle.localizedString(forKey: key, value: value, table: table)
    }
}
