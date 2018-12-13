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

class OutboundClientDecorator: RequestDecorator {

    var  headerKey: String { return "X-Outbound-Client" }

    let headerValue: String

    init(with headerValue: String) {
        self.headerValue = headerValue
    }
}

class OutboundGUIDDecorator: RequestDecorator {
    
    var  headerKey: String { return "X-Outbound-GUID" }
    
    var headerValue: String {
        return UUID().uuidString
    }
    
    init(with headerValue: String) {}
}

class ConnectGUIDDecorator: OutboundGUIDDecorator {
    
    override var headerValue: String {
        return UUID().uuidString
    }
    
    init() {super .init(with: "")}
}

class OutboundKeyDecorator: RequestDecorator {
    
    var  headerKey: String { return "X-Outbound-Key" }
    
    let headerValue: String
    
    init(with headerValue: String) {
        self.headerValue = headerValue
    }
}
