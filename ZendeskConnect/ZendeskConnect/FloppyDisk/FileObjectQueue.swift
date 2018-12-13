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

class FileObjectQueue<Object: Codable>: ObjectQueue<Object> {
    
    typealias Element = Object
    
    let queue: QueueFile
    let converter: Converter
    
    init(queue: QueueFile, converter: Converter = DefaultConverter()) {
        self.queue = queue
        self.converter = converter
    }
    
    override var size: UInt {
        return queue.size
    }
    
    override func add(_ entry: Object) {
        do {
            let data = try converter.toData(entry)
            queue.add(data)
        } catch {
            print(error)
        }
    }
    
    override func peek() -> Object? {
        guard let data = queue.peek() else { return nil }
        return try? converter.from(data)
    }
    
    override func peek(_ max: UInt) -> [Object] {
        let end = Swift.min(size, max)
        var it = makeIterator()
        var peekedList: [Object] = []
        for _ in 0..<end {
            if let next = it.next() {
                peekedList.append(next)
            }
        }
        return peekedList
    }

    override func remove() {
        remove(1)
    }
    
    override func remove(_ n: UInt) {
        queue.remove(n)
    }
}

extension FileObjectQueue: Sequence {
    
    func makeIterator() -> FileObjectQueue.ObjectIterator {
        return FileObjectQueue.ObjectIterator(iterator: queue.makeIterator(), converter: converter)
    }
    
    struct ObjectIterator: IteratorProtocol {
        var iterator: QueueFile.FileElementIterator
        var converter: Converter
        
        mutating func next() -> Element? {
            
            guard
                let current = iterator.next(),
                let converted: Element = try? converter.from(current) else { return nil }
            
            return converted
        }
        
        typealias Element = Object
        
    }
}
