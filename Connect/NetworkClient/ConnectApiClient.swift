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

let OutboundHostDomain = "api.outbound.io"
let PlatformString = "ios"
let NoNetworkLog = "No network. Can't send {queue} queue, skipping network call."
let ConfigFetchInterval = 3600

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

typealias ConfigUpdateHandler = (Result<Config>) -> Void

protocol ConnectApi {
    func register(_ token: Data, for userId: String)
    func disable(_ token: Data, for userId: String)
    func flush(_ eventQueue: Queue<Event>)
    func flush(_ identifyQueue: Queue<User>)
    func scheduleConfigFetch(start: DispatchWallTime,
                             reapeatFrequency: DispatchTimeInterval,
                             leeway: DispatchTimeInterval,
                             handler: @escaping ConfigUpdateHandler)
}

extension ConnectApi {
    func scheduleConfigFetch(start: DispatchWallTime,
                             reapeatFrequency: DispatchTimeInterval = .seconds(ConfigFetchInterval),
                             leeway: DispatchTimeInterval = .seconds(1),
                             handler: @escaping ConfigUpdateHandler) {
        return scheduleConfigFetch(start: start,
                                   reapeatFrequency: reapeatFrequency,
                                   leeway: leeway,
                                   handler: handler)
    }
}

class ConnectApiClient: ConnectApi {
    
    private let dispatchGroup: DispatchGroup
    private let operationQueue: OperationQueue
    
    private let client: Client
    private let eventProvider: EventProvider
    private let identifyProvider: IdentifyProvider
    private let pushProvider: PushProvider
    private let configProvider: ConfigProvider
    private var configTimer: DispatchSourceTimer?
    
    init(client: Client, dispatchGroup: DispatchGroup = DispatchGroup()) {
        self.client = client
        self.dispatchGroup = dispatchGroup
        
        // Inject?
        eventProvider = EventProvider(with: client)
        identifyProvider = IdentifyProvider(with: client)
        pushProvider = PushProvider(with: client)
        configProvider = ConfigProvider(with: client)
        
        operationQueue = OperationQueue()
        operationQueue.name = "com.zendesk.connect.queue"
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .background
    }
    
    func scheduleConfigFetch(start: DispatchWallTime,
                             reapeatFrequency: DispatchTimeInterval = .seconds(ConfigFetchInterval),
                             leeway: DispatchTimeInterval = .seconds(1),
                             handler: @escaping ConfigUpdateHandler)  {
        
        guard configTimer == nil else { return }
        
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(wallDeadline: start,
                       repeating: reapeatFrequency,
                       leeway: leeway)
        
        timer.setEventHandler { [configProvider] in
            configProvider.config(platform: PlatformString,
                                  version: ConnectVersionString,
                                  completion: handler)
        }
        
        timer.resume()
        configTimer = timer
    }
    
    func register(_ token: Data, for userId: String) {
        
        let body = PushRegistration(timestamp: Date().timeIntervalSince1970,
                                    userId: userId,
                                    token: token.hexString)
        
        pushProvider.register(body: body) { (result) in
            switch result {
            case .success(_):
                Logger.debug("Push registration success: registered token: \(token.hexString) , against user ID \(userId)")
            case .failure(let error):
                Logger.debug("Push registration failed: \(error.localizedDescription)")
            }
        }
    }
    
    func disable(_ token: Data, for userId: String) {
        
        let body = PushRegistration(timestamp: Date().timeIntervalSince1970,
                                    userId: userId,
                                    token: token.hexString)
        
        pushProvider.unregister(body: body) { (result) in
            switch result {
            case .success(_):
                Logger.debug("Disable token success: disabled token: \(token.hexString) , against user ID \(userId)")
            case .failure(let error):
                Logger.debug("Disable token failed: \(error.localizedDescription)")
            }
        }
    }
    
    func flush(_ eventQueue: Queue<Event>) {
        
        guard Reachability.status(for: OutboundHostDomain) else {
            Logger.debug(NoNetworkLog.replacingOccurrences(of: "{queue}", with: "event"))
            return
        }
        
        guard eventQueue.size > 0 else { return }
        
        let eventOperation = EventOperation(provider: eventProvider,
                                            queue: eventQueue,
                                            group: dispatchGroup)
        operationQueue.addOperation(eventOperation)
    }
    
    func flush(_ identifyQueue: Queue<User>) {
        
        guard Reachability.status(for: OutboundHostDomain)  else {
            Logger.debug(NoNetworkLog.replacingOccurrences(of: "{queue}", with: "identify"))
            return
        }
        
        guard identifyQueue.size > 0 else { return }
        
        let identifyOperation = IdentifyOperation(provider: identifyProvider,
                                                  queue: identifyQueue,
                                                  group: dispatchGroup)
        operationQueue.addOperation(identifyOperation)
    }
}
