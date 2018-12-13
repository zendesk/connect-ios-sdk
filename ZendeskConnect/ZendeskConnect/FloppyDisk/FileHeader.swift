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

struct FileHeader {
    static let headerLength = UInt64(MemoryLayout<FileHeader>.size)
    static let `default` = FileHeader(elementCount: 0,
                                      firstOffset: FileHeader.headerLength,
                                      lastOffset: FileHeader.headerLength)
    let version: UInt8
    let fileLength: UInt64
    let elementCount: UInt
    let firstOffset: UInt64
    let lastOffset: UInt64
    
    init(version: UInt8 = 1,
         fileLength: UInt64 = 0,
         elementCount: UInt,
         firstOffset: UInt64,
         lastOffset: UInt64) {
        
        self.version = version
        self.fileLength = fileLength
        self.elementCount = elementCount
        self.firstOffset = firstOffset
        self.lastOffset = lastOffset
    }
}
