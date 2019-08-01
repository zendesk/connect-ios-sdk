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

class Queue<Object: Codable> {

    static func create<T>(fileName: String) -> Queue<T> {
        do {
            let url = try FileUtility.url(name: fileName)
            let fileHandle = try FileUtility.handle(url: url)
            let fileQueue = QueueFile(fileHandle: fileHandle)
            return Queue<T>(objectQueue: ObjectQueue<T>.create(fileQueue))
        } catch {
            Logger.debug("Could not create backing file \"\(fileName)\" for queue: \(error.localizedDescription)")
            Logger.debug("Falling back to in memory queue.")
            return Queue<T>(objectQueue: ObjectQueue<T>.createInMemory())
        }
    }
    
    var size: UInt {
        return objectQueue.size
    }
    
    private var objectQueue: ObjectQueue<Object>
    
    init(objectQueue: ObjectQueue<Object>) {
        self.objectQueue = objectQueue
    }
    
    func add(entry: Object) {
        objectQueue.add(entry)
    }
    
    func peek() -> Object? {
        return objectQueue.peek()
    }
    
    func peek(_ max: UInt) -> [Object] {
        return objectQueue.peek(max)
    }
    
    func remove() {
        objectQueue.remove()
    }
    
    func remove(_ n: UInt) {
        objectQueue.remove(n)
    }
    
    func clear() {
        objectQueue.clear()
    }
}


