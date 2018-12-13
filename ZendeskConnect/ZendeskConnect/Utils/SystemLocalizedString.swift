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


/// Use the system localised strings.
enum SystemLocalizedString {

    /// Returns a localised string for OK.
    static var ok: String {
        return string(for: "OK")
    }

    /// Returns a localised string for Concel.
    static var cancel: String {
        return string(for: "Cancel")
    }


    /// Gets UIKit bundle and reads the localised string for the key provided.
    ///
    /// - Parameters:
    ///   - key: The key for a string in the table identified by tableName.
    ///   - value: The value to return if key is nil or if a localized string for key can’t be found in the table.
    ///   - table: The receiver’s string table to search. If tableName is nil or is an empty string, the method attempts to use the table in Localizable.strings.
    /// - Returns: A localized version of the string designated by key in table tableName. 
    private static func string(for key: String, default value: String? = nil, table: String? = nil) -> String {
        guard let bundle = Bundle(identifier: "com.apple.UIKit") else {
            return key
        }
        return bundle.localizedString(forKey: key, value: value, table: table)
    }
}
