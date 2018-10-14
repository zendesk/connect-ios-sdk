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

struct FileElement {
    
    static let headerLength = UInt64(MemoryLayout<FileElement>.size)
    let offset: UInt64
    let length: Int
    
    var isEmpty: Bool {
        return length == 0
    }
    
    func valueOffset() -> UInt64 {
        return offset + FileElement.headerLength
    }
    
    func next() -> UInt64 {
        return valueOffset() + UInt64(length)
    }
}

