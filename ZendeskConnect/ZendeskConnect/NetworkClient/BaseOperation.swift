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

typealias RemoveHandler = (Result<Empty>) -> ()

class BaseOperation<T: Codable>: Operation {
    let queue: Queue<T>
    let group: DispatchGroup
    let batchSize: UInt
    let timeout = 15
    
    init(queue: Queue<T>,
         batchSize: UInt = 100,
         group: DispatchGroup) {
        
        self.queue = queue
        self.batchSize = batchSize
        self.group = group
    }
}
