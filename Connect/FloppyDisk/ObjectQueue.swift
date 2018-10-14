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

let abstractError = "Do not use ObjectQueue directly. Create a FileObjectQueue or InMemoryObjectQueue"

class ObjectQueue<Object> {
    
    var isEmpty: Bool {return size == 0}
    var size: UInt { preconditionFailure(abstractError) }
    func add(_ entry: Object) { preconditionFailure(abstractError) }
    func peek() -> Object? { preconditionFailure(abstractError) }
    func peek(_ max: UInt) -> [Object] { preconditionFailure(abstractError) }
    func remove() { preconditionFailure(abstractError) }
    func remove(_ n: UInt) { preconditionFailure(abstractError) }
    func asArray() -> [Object]  { return peek(size) }
    func clear() { remove(size) }

    static func create<T>(_ queueFile: QueueFile, converter: Converter = DefaultConverter()) -> FileObjectQueue<T> {
        return FileObjectQueue<T>(queue: queueFile, converter: converter);
    }
    
    static func createInMemory<T>() -> InMemoryObjectQueue<T> {
        return InMemoryObjectQueue()
    }
}
