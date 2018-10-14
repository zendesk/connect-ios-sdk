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

class IdentifyOperation: BaseOperation<User> {
    let provider: IdentifyProvider
    
    required init(provider: IdentifyProvider,
                  queue: Queue<User>,
                  group: DispatchGroup) {
        self.provider = provider
        super.init(queue: queue, group: group)
    }
    
    override func main() {
        
        while queue.size != 0 && !isCancelled {
            let peeked = queue.peek(batchSize)
            
            group.enter()
            
            let count = UInt(peeked.count)
            
            let remove: RemoveHandler = { [cancel, peeked, queue, group] result in
                defer { group.leave() }
                switch result {
                case .success(_):
                    queue.remove(count)
                    Logger.debug("Sent \(count) identify event\(count == 1 ? "" : "s")")
                case .failure(let error):
                    Logger.debug("Failed to send \(count) identify event\(count == 1 ? "" : "s") with error: \(error.localizedDescription)")
                    cancel()
                }
            }
            
            if count == 1 {
                provider.identify(body: peeked[0], completion: remove)
            } else {
                provider.identifyBatch(body: peeked, completion: remove)
            }
            _ = group.wait(timeout: .now() + .seconds(timeout))
        }
    }
}
