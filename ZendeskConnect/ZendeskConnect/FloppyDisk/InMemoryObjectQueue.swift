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

class InMemoryObjectQueue<Object: Codable>: ObjectQueue<Object> {
    
    typealias Element = Object
    
    var entries: [Object] = []
    
    override var size: UInt {
        return UInt(entries.count)
    }
    
    override func add(_ entry: Object) {
        entries.append(entry)
    }
    
    override func peek() -> Object? {
        return entries.first
    }
    
    override func peek(_ max: UInt) -> [Object] {
        let end = Swift.min(size, max)
        return Array(entries[0..<Int(end)])
    }
    
    override func remove() {
        remove(1)
    }
    
    override func remove(_ n: UInt) {
        entries.removeFirst(Int(n))
    }
}

extension InMemoryObjectQueue: Sequence {
    func makeIterator() -> InMemoryObjectQueue.ObjectIterator {
        return InMemoryObjectQueue.ObjectIterator(delegate: entries.makeIterator())
    }
    
    struct ObjectIterator: IteratorProtocol {
        var delegate: IndexingIterator<[Object]>
        mutating func next() -> Element? {
            return delegate.next()
        }
        typealias Element = Object
    }
}
