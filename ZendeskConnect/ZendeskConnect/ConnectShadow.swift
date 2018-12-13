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


/// Log message for when SDK is disabled from config.
let ConnectNotEnabledLog = "Connect SDK is not enabled."

/// ConnectShadow
final class ConnectShadow {

    private var presenter: AdminPresenter

    /// Persistant queue for evens.
    var eventQueue: Queue<Event>

    /// Persistant queue for identify calls.
    var identifyQueue: Queue<User>

    /// Network client
    let connectClient: ConnectAPI

    /// Config storage.
    let configStorage: ConfigStorable

    /// Push notification handler.
    let pushHandler: ConnectPushNotificationHandler

    /// Returns the stored config, or a default config if storage is empty.
    var configuration: Config {
        get {
            guard let config = configStorage.readConfig() else {
                return Config(enabled: true, account: nil)
            }
            return config
        }
    }

    /// User storage.
    let userStorage: UserStorable

    /// Current user. Will either be a temporary user or an identified user. 
    var user: User {
        didSet {
            userStorage.store(user)
        }
    }

    let pushRegistration = ConnectPushRegistration()
    let pushRegistrationDelegate = ConnectPushRegistrationDelegate()

    /// The private key for the connect account.
    let privateKey: String


    /// Create an instance of Connect.
    ///
    /// - Parameters:
    ///   - privateKey: development or production key.
    ///   - userStorage: user storage.
    ///   - configStorage: config storage.
    ///   - nextConfigFetchTime: time of the next api call to fetch and store a configuration.
    ///   - repeatFrequency: how often the configuration fetch happens.
    ///   - connectClient: api client.
    init(privateKey: String,
         userStorage: UserStorable,
         configStorage: ConfigStorable,
         nextConfigFetchTime: DispatchWallTime = .seconds(ConfigFetchInterval),
         repeatFrequency: DispatchTimeInterval = .seconds(ConfigFetchInterval),
         connectClient: ConnectAPI) {

        // Set our private key.
        self.privateKey = privateKey

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
                                          repeatFrequency: repeatFrequency) { [configStorage] result in
                                            switch result {
                                            case .success(let config, _):
                                                Logger.debug("Successfully fetched config.")
                                                configStorage.store(config: config)
                                            case .failure(let error):
                                                Logger.debug("Failed to fetch config: \(error.localizedDescription)")
                                            }
        }

        // Create queues
        eventQueue = Queue<Event>.create(fileName: "events.dat")
        identifyQueue = Queue<User>.create(fileName: "identities.dat")

        // Setup push registration and handling. 
        pushRegistration.delegate = pushRegistrationDelegate
        pushHandler = ConnectPushNotificationHandler(connectClient: connectClient)

        presenter = AdminPresenter(userStorage: userStorage, connectClient: connectClient)
        AdminPresenter.addGestureTarget(presenter, action: #selector(AdminPresenter.present(_:)))
    }


    /// Logout when you want to stop tracking events for a user.
    /// You need to logout a user before identifying a new user, otherwise
    /// the new user will be aliased with the previous user.
    func logoutUser() {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }
        disablePushToken()
        eventQueue.clear()
        identifyQueue.clear()
        user = User.createAnonymous()
    }


    /// You identify a user with Connect each time you create
    /// a new user or update an existing user in your system.
    ///
    /// It is recommended that you send as much information
    /// about the user as possible. Any attribute you send can be used in
    /// the messages from Connect.
    ///
    /// - Parameter user: a user to identify
    func identifyUser(_ user: User) {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }

        Logger.debug("Identifying user: \(user)")
        self.user = user
        identifyQueue.add(entry: user)

        flushQueues()
        pushRegistration.attemptAfterIdentify(configuration: configuration)
    }


    /// You can track unlimited events using the Connect API. Any event you send
    /// can be used as a trigger event for a message or the goal event of a desired
    /// user flow which triggers a message when not completed within a set period of time.
    ///
    /// - Parameter event: an event to send to the Connect API.
    func trackEvent(_ event: Event) {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }

        let userEvent = Event(userId: user.userId, properties: event.properties, event: event.event)

        Logger.debug("Track event: \(userEvent)")
        eventQueue.add(entry: userEvent)

        flushQueues()

        pushRegistration.attemptAfter(event: userEvent.event, configuration: configuration)
    }


    /// Avoid queue starvation by scheduling both
    private func flushQueues() {
        connectClient.flush(eventQueue)
        connectClient.flush(identifyQueue)
    }

    /// If you want your app to send push notifications, you can register the device token
    /// for the user independently of an identify call.
    ///
    /// - Parameter token: The Data token obtained from `UIApplicationDelegate`'s method.
    func registerPushToken(_ token: Data) {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }
        userStorage.store(token)
        connectClient.register(token, for: user.userId)
    }


    /// Disable the device's push token to tell Connect not to send notifications to this device.
    ///
    /// - Parameter token: push token data.
    func disablePushToken() {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }
        guard let token = userStorage.readToken() else {
            Logger.debug("Failed to read token from storage.")
            return
        }
        
        connectClient.disable(token, for: user.userId)
    }
}

extension ConnectShadow: Equatable {
    static func == (lhs: ConnectShadow, rhs: ConnectShadow) -> Bool {
        return lhs.privateKey == rhs.privateKey
    }
}
