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

/// PushResource is a simple struct to provide a simplified way to construct Resource instances
struct PushResource {
    
    static func permissionGranted(body: PermissionRequested) -> Resource<PermissionRequested, Empty> {
        let url = URL(string: "/i/ios/permissions/granted")!
        return Resource(url: url, method: .post(body), response: Empty.self)
    }
    
    
    static func permissionRequested(body: PermissionRequested) -> Resource<PermissionRequested, Empty> {
        let url = URL(string: "/i/ios/permissions/requested")!
        return Resource(url: url, method: .post(body), response: Empty.self)
    }
    
    
    static func register(platform: String, body: PushRegistration) -> Resource<PushRegistration, Empty> {
        let pathParams = [
            "platform" : platform
        ]
        let urlString = String.format(string: "/v2/{platform}/register", with: pathParams)
        let url = URL(string: urlString)!
        return Resource(url: url, method: .post(body), response: Empty.self)
    }
    
    
    static func unregister(platform: String, body: PushRegistration) -> Resource<PushRegistration, Empty> {
        let pathParams = [
            "platform" : platform
        ]
        let urlString = String.format(string: "/v2/{platform}/disable", with: pathParams)
        let url = URL(string: urlString)!
        return Resource(url: url, method: .post(body), response: Empty.self)
    }
    
}
