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

let ConnectVersionString = "1.2.0"

extension DispatchWallTime {
    static func seconds(_ n: Int) -> DispatchWallTime {
        return .now() + DispatchTimeInterval.seconds(n)
    }
}


@objc(ZCNConnect)
/// Connect
public class Connect: NSObject {
    
    /// Persistant queue for evens.
    var eventQueue: Queue<Event>
    
    /// Persistant queue for identify calls.
    var identifyQueue: Queue<User>
    
    /// Network client
    var connectClient: ConnectApi
    
    /// Config storage.
    let configStorage: ConfigStorable
    
    /// Returns the stored config, or a default config if storage is empty.
    var configuration: Config {
        get {
            guard let config = configStorage.readConfig() else {
                return Config(enabled: true, account: nil)
            }
            return config
        }
    }
    
    let userStorage: UserStorable
    
    /// The user which was last identified. Or if no
    /// call to idnetify has been made, an anonymous user.
    ///
    /// - This is an Objective-C wrapper for the swift interface.
    ///
    /// - Returns: The current user being tracked.
    @objc public func currentUser() -> ZCNUser {
        return ZCNUser(user: user)
    }
    
    /// The user which was last identified. Or if noß
    /// call to idnetify has been made, an anonymous user.
    ///
    /// - Returns: The current user being tracked.
    public func currentUser() -> User {
        return user
    }
    
    private(set) var user: User {
        didSet {
            userStorage.store(user)
        }
    }

    /// The environment key for the connect account.
    private let environmentKey: String
    
    @objc required public init(environmentKey: String) {
        // Set our environment key.
        self.environmentKey = environmentKey
        
        // Create user storage.
        userStorage = UserStorage()
        
        // Determine whether we need to create an anonymous user.
        if let user = userStorage.readUser() {
            self.user = user
            Logger.debug("Found stored user with id:\(user.userId).")
        } else {
            Logger.debug("No stored user found. Creating anonymous user.")
            // create an anonymous user and store it.
            user = User.createAnonymous()
        }
        
        // Set up base network client.
        let client = Client(host: URL(string: "https://\(OutboundHostDomain)")!,
                            requestDecorator: [OutboundClientDecorator(with: "\(PlatformString)/\(ConnectVersionString)"),
                                               OutboundKeyDecorator(with: environmentKey),
                                               ConnectGUIDDecorator()])
        
        // Set up API wrapper
        connectClient = ConnectApiClient(client: client)
        
        
        configStorage = ConfigStorage()
        
        // Schedule config fetch an hour from now.
        var nextConfigFetchTime: DispatchWallTime = .seconds(3600)
        
        // if storage is empty make a config call now
        if configStorage.readConfig() == nil {
            nextConfigFetchTime = .now()
        }
        
        // Schedule config fetching
        connectClient.scheduleConfigFetch(start: nextConfigFetchTime) { [configStorage] result in
            switch result {
            case .success(let config, _):
                Logger.debug("Successfully fetched config.")
                configStorage.store(config: config)
            case .failure(let error):
                Logger.debug("Failed to fetch setting: \(error.localizedDescription)")
            }
        }
        
        // Create queues
        eventQueue = Queue<Event>.create(fileName: "events.dat")
        identifyQueue = Queue<User>.create(fileName: "identities.dat")
    }
    
    /// Logout when you want to stop tracking events for a user.
    /// You need to logout a user before identifying a new user, otherwise
    /// the new user will be aliased with the previous user.
    @objc public func logout() {
        user = User.createAnonymous()
    }
    
    /// You identify a user with Connect each time you create
    /// a new user or update an existing user in your system.
    ///
    /// It is recommended that you send as much information
    /// about the user as possible. Any attribute you send can be used in
    /// the messages from Connect.
    ///
    /// - This is an Objective-C wrapper for the swift interface.
    ///
    /// - Parameter user: a user to identify
    @objc public func identify(user: ZCNUser) {
        identify(user: user.internalUser)
    }
    
    
    /// You identify a user with Connect each time you create
    /// a new user or update an existing user in your system.
    ///
    /// It is recommended that you send as much information
    /// about the user as possible. Any attribute you send can be used in
    /// the messages from Connect.
    ///
    /// - Parameter user: a user to identify
    public func identify(user: User) {
        guard configuration.enabled else {
            Logger.debug("The SDK is disabled due to remote kill")
            return
        }
        
        Logger.debug("Identifying user: \(user)")
        self.user = user
        identifyQueue.add(entry: user)
        
        flushQueues()
    }

    /// You can track unlimited events using the Connect API. Any event you send
    /// can be used as a trigger event for a message or the goal event of a desired
    /// user flow which triggers a message when not completed within a set period of time.
    ///
    /// - This is an Objective-C wrapper for the swift interface.
    ///
    /// - Parameter event: an event to send to the Connect API.
    @objc public func track(event: ZCNEvent) {
        track(event: event.internalEvent)
    }
    
    /// You can track unlimited events using the Connect API. Any event you send
    /// can be used as a trigger event for a message or the goal event of a desired
    /// user flow which triggers a message when not completed within a set period of time.
    ///
    /// - Parameter event: an event to send to the Connect API.
    public func track(event: Event) {
        guard configuration.enabled else {
            Logger.debug("The SDK is disabled due to remote kill")
            return
        }
        
        Logger.debug("Track event: \(event)")
        eventQueue.add(entry: event)
        
        flushQueues()
    }
    
    
    /// Avoid queue starvation by scheduling both
    func flushQueues() {
        connectClient.flush(eventQueue)
        connectClient.flush(identifyQueue)
    }

    /// If you want your app to send push notifications, you can register the device token
    /// for the user independently of an identify call.
    ///
    /// - Parameter token: The Data token obtained from `UIApplicationDelegate`'s method.
    @objc public func registerPushToken(_ token: Data) {
        guard configuration.enabled else {
            Logger.debug("The SDK is disabled due to remote kill")
            return
        }
        connectClient.register(token, for: user.userId)
    }
    
    
    /// Disable the device's push token to tell Connect not to send notifications to this device.
    ///
    /// - Parameter token: push token data.
    @objc public func disablePushToken() {
        guard configuration.enabled else {
            Logger.debug("The SDK is disabled due to remote kill")
            return
        }
        guard let token = userStorage.readToken() else {
            Logger.debug("Failed to read token from storage.")
            return
        }
        connectClient.disable(token, for: user.userId)
    }

    
    /// Testing Only
    init(with environmentKey: String,
         userStorage: UserStorable,
         configStorage: ConfigStorable,
         nextConfigFetchTime: DispatchWallTime = .seconds(ConfigFetchInterval),
         reapeatFrequency: DispatchTimeInterval = .seconds(ConfigFetchInterval),
         connectClient: ConnectApi) {
        // Set our environment key.
        self.environmentKey = environmentKey
        
        // Create user storage.
        self.userStorage = userStorage
        
        // Determine whether we need to create an anonymous user.
        if let user = userStorage.readUser() {
            self.user = user
            Logger.debug("Found stored user with id:\(user.userId).")
        } else {
            Logger.debug("No stored user found. Creating anonymous user.")
            // create an anonymous user and store it.
            user = User.createAnonymous()
        }
        
        // Set up API wrapper
        self.connectClient = connectClient
        
        self.configStorage = configStorage
        
        // Schedule config fetch an hour from now.
        var nextConfigFetchTime = nextConfigFetchTime
        
        // if storage is empty make a config call now
        if configStorage.readConfig() == nil {
            nextConfigFetchTime = .now()
        }
        
        // Schedule config fetching
        connectClient.scheduleConfigFetch(start: nextConfigFetchTime,
                                    reapeatFrequency: reapeatFrequency) { [configStorage] result in
                                        switch result {
                                        case .success(let config, _):
                                            Logger.debug("Successfully fetched config.")
                                            configStorage.store(config: config)
                                        case .failure(let error):
                                            Logger.debug("Failed to fetch setting: \(error.localizedDescription)")
                                        }
        }
        
        // Create queues
        eventQueue = Queue<Event>.create(fileName: "events.dat")
        identifyQueue = Queue<User>.create(fileName: "identities.dat")
    }
}


