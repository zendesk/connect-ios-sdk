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

struct IPMViewModel {

    let oid: String
    let logo: UIImage?
    let heading: String
    let message: String
    let messageFontColor: UIColor
    let headingFontColor: UIColor
    let backgroundColor: UIColor
    let buttonText: String
    let buttonBackgroundColor: UIColor
    let buttonTextColor: UIColor
    let action: URL?
    let timeToLive: TimeInterval

    init(ipm: IPM, image: UIImage?) {
        oid = ipm.instanceIdentifier
        logo = image
        heading = ipm.heading
        message = ipm.message
        headingFontColor = UIColor(hexString: ipm.headingFontColor) ?? .black
        backgroundColor = UIColor(hexString: ipm.backgroundColor) ?? .white
        messageFontColor = UIColor(hexString: ipm.messageFontColor) ?? .black
        buttonText = ipm.buttonText
        buttonTextColor = UIColor(hexString: ipm.buttonTextColor) ?? .white
        buttonBackgroundColor = UIColor(hexString: ipm.buttonBackgroundColor) ?? .blue
        action = ipm.action
        timeToLive = ipm.timeToLive
    }
}
