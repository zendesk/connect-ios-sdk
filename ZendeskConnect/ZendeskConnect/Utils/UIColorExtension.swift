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

extension UIColor {

    convenience init?(hexString: String, alpha: CGFloat = 1.0)
    {
        let redHexBitMask: UInt64 = 0xff0000
        let greenHexBitMask: UInt64 = 0xff00
        let blueHexBitMask: UInt64 = 0xff

        let strippedHash = hexString.filter({$0 != "#"})
        guard strippedHash.count == 6 else {
            return nil
        }

        let scanner = Scanner(string: strippedHash)

        var rgbValue: UInt64 = 0
        guard scanner.scanHexInt64(&rgbValue) else {
            return nil
        }

        let red = (rgbValue & redHexBitMask) >> 16
        let green = (rgbValue & greenHexBitMask) >> 8
        let blue = rgbValue & blueHexBitMask

        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255, alpha: alpha
        )
    }
}
