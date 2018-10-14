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

/// RequestDecorator protocol used in order to standardize the delivery of the authentication token and auth error handling
protocol RequestDecorator {
    
    /// Returns a String of the current header value used for authentication, eg: `Authorization`
    var headerKey: String {get}
    
    /// Returns a string of the current authentication token, includes scheme pre-fix, eg: `Bearer ...`
    var headerValue: String {get}
}
