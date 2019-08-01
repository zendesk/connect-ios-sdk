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

/// Short wrapper on `DispatchQueue.main.async` {}
///
/// - Parameter onMain: Something that should be called on the main thread.
func onMain(_ onMain: @escaping () -> Void) {
    DispatchQueue.main.async {
        onMain()
    }
}
