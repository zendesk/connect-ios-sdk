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
typealias PushProviderCompletion = (Bool) -> Void

protocol ConnectAPI {
    var autoFlush: Bool { get set }
    func flush()
    func register(_ token: Data, for userId: String)
    func disable(_ token: Data, for userId: String)
    func identifyUser(_ user: User)
    func track(_ event: Event)
    func track(uninstall: UninstallTracker, completion: PushProviderCompletion?)
    func send(received metric: PushBasicMetric, completion: PushProviderCompletion?)
    func send(opened metric: PushBasicMetric, completion: PushProviderCompletion?)
    func scheduleConfigFetch(start: DispatchWallTime,
                             repeatFrequency: DispatchTimeInterval,
                             leeway: DispatchTimeInterval,
                             handler: @escaping ConfigUpdateHandler)
    func testSend(code: Int, deviceToken: Data, completion: @escaping (Bool) -> Void)
    func clear()
}

extension ConnectAPI {
    func scheduleConfigFetch(start: DispatchWallTime,
                             repeatFrequency: DispatchTimeInterval = .seconds(ConfigFetchInterval),
                             leeway: DispatchTimeInterval = .seconds(1),
                             handler: @escaping ConfigUpdateHandler) {
        return scheduleConfigFetch(start: start,
                                   repeatFrequency: repeatFrequency,
                                   leeway: leeway,
                                   handler: handler)
    }
}

class ConnectAPIClient: ConnectAPI {

    var autoFlush: Bool = true

    private var eventQueue: Queue<Event>
    private var identifyQueue: Queue<User>

    private let dispatchGroup: DispatchGroup
    private let operationQueue: OperationQueue

    private let client: Client
    private let eventProvider: EventProvider
    private let identifyProvider: IdentifyProvider
    private let pushProvider: PushProvider
    private let configProvider: ConfigProvider
    private let metricsProvider: MetricsProvider
    private let testSendProvider: TestSendProvider
    private var configTimer: DispatchSourceTimer?

    init(client: Client,
         identifyQueue: Queue<User>,
         eventQueue: Queue<Event>,
         dispatchGroup: DispatchGroup = DispatchGroup(),
         metricsProvider: MetricsProvider? = nil) {
        self.client = client
        self.identifyQueue = identifyQueue
        self.eventQueue = eventQueue
        self.dispatchGroup = dispatchGroup

        eventProvider = EventProvider(with: client)
        identifyProvider = IdentifyProvider(with: client)
        pushProvider = PushProvider(with: client)
        configProvider = ConfigProvider(with: client)
        self.metricsProvider = metricsProvider ?? MetricsProvider(with: client)
        testSendProvider = TestSendProvider(with: client)

        operationQueue = OperationQueue()
        operationQueue.name = "com.zendesk.connect.queue"
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .background
    }

    func track(uninstall: UninstallTracker, completion: PushProviderCompletion? = nil) {
        metricsProvider.uninstallTracker(platform: "ios", body: uninstall) { result in
            switch result {
            case .success(_):
                Logger.debug("Uninstall metric success. \(uninstall.i ?? "no-id")")
                completion?(true)
            case .failure(let error):
                Logger.debug("Sending uninstall metric failed: \(error.localizedDescription)")
                completion?(false)
            }
        }
    }

    func send(received metric: PushBasicMetric, completion: PushProviderCompletion? = nil) {
        metricsProvider.received(body: metric) { result in
            switch result {
            case .success(_):
                Logger.debug("Push metric 'received' success. \(metric._oid ?? "no-id")")
                completion?(true)
            case .failure(let error):
                Logger.debug("Sending push metric 'received' failed: \(error.localizedDescription)")
                completion?(false)
            }
        }
    }

    func send(opened metric: PushBasicMetric, completion: PushProviderCompletion? = nil) {
        metricsProvider.opened(body: metric) { result in
            switch result {
            case .success(_):
                Logger.debug("Push metric 'opened' success. \(metric._oid ?? "no-id")")
                completion?(true)
            case .failure(let error):
                Logger.debug("Sending push metric 'opened' failed: \(error.localizedDescription)")
                completion?(false)
            }
        }
    }

    func scheduleConfigFetch(start: DispatchWallTime,
                             repeatFrequency: DispatchTimeInterval = .seconds(ConfigFetchInterval),
                             leeway: DispatchTimeInterval = .seconds(1),
                             handler: @escaping ConfigUpdateHandler)  {

        guard configTimer == nil else { return }

        let timer = DispatchSource.makeTimerSource()
        timer.schedule(wallDeadline: start,
                       repeating: repeatFrequency,
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

    func testSend(code: Int, deviceToken: Data, completion: @escaping (Bool) -> Void) {

        let device = PairDevice(code: code, deviceToken: deviceToken.hexString, deviceName: UIDevice.current.name)
        testSendProvider.pairDevice(body: device) { result in
            switch result {
            case .success(_, let response):
                guard let res = response as? HTTPURLResponse else {
                    completion(false)
                    return
                }
                completion(200...299 ~= res.statusCode)
            case .failure(_):
                completion(false)
            }
        }
    }

    func track(_ event: Event) {
        Logger.debug("Track event: \(event)")
        eventQueue.add(entry: event)

        if autoFlush {
            flush(eventQueue)
        }
    }

    func identifyUser(_ user: User) {
        Logger.debug("Identifying user: \(user)")
        identifyQueue.add(entry: user)

        if autoFlush {
            flush()
        }
    }

    func flush() {
        flush(eventQueue)
        flush(identifyQueue)
    }

    private func flush(_ eventQueue: Queue<Event>) {

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

    private func flush(_ identifyQueue: Queue<User>) {

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

    func clear() {
        eventQueue.clear()
        identifyQueue.clear()
    }
}
