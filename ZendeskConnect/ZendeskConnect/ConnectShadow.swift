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

    /// Network client
    let connectClient: ConnectAPI

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

    let pushFactory: PushStrategyFactory
    let silentPushFactory: SilentPushStrategyFactory

    /// The private key for the `Connect` account.
    let privateKey: String


    /// Create an instance of `Connect`.
    ///
    /// - Parameters:
    ///   - privateKey: Development or production key.
    ///   - userStorage: User storage.
    ///   - configStorage: Config storage.
    ///   - nextConfigFetchTime: Time of the next API call to fetch and store a configuration.
    ///   - repeatFrequency: How often the configuration fetch happens.
    ///   - connectClient: API client.
    init(privateKey: String,
         userStorage: UserStorable,
         configStorage: ConfigStorable,
         nextConfigFetchTime: DispatchWallTime = .seconds(ConfigFetchInterval),
         repeatFrequency: DispatchTimeInterval = .seconds(ConfigFetchInterval),
         connectClient: ConnectAPI,
         pushFactory: PushStrategyFactory = ConnectPushStrategyFactory(),
         silentPushFactory: SilentPushStrategyFactory) {

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

        // If storage is empty make a config call now
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

        // Setup push registration and handling. 
        pushRegistration.delegate = pushRegistrationDelegate

        self.pushFactory = pushFactory
        self.silentPushFactory = silentPushFactory
        
        presenter = AdminPresenter(userStorage: userStorage, connectClient: connectClient)
        AdminPresenter.addGestureTarget(presenter, action: #selector(AdminPresenter.present(_:)))
    }

    /// Logout when you want to stop tracking events for a `User`.
    /// You need to logout a `User` before identifying a new `User`, otherwise
    /// the new `User` will be aliased with the previous `User`.
    func logoutUser() {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }
        disablePushToken()
        connectClient.clear()
        user = User.createAnonymous()
    }

    /// You identify a `User` with `Connect` each time you create
    /// a new `User` or update an existing `User` in your system.
    ///
    /// It is recommended that you send as much information
    /// about the `User` as possible. Any attribute you send can be used in
    /// the messages from `Connect`.
    ///
    /// - Parameter user: a user to identify
    func identifyUser(_ user: User) {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }

        self.user = user
        connectClient.identifyUser(user)
        pushRegistration.attemptAfterIdentify(configuration: configuration)
    }

    /// You can track unlimited events using the `Connect` API. Any event you send
    /// can be used as a trigger event for a message, or the goal event of a desired
    /// user flow, which triggers a message when not completed within a set period of time.
    ///
    /// - Parameter event: An `Event` to send to the `Connect` API.
    func trackEvent(_ event: Event) {
        guard configuration.enabled else {
            Logger.debug(ConnectNotEnabledLog)
            return
        }

        let userEvent = Event(userId: user.userId, properties: event.properties, event: event.event)
        connectClient.track(userEvent)
        pushRegistration.attemptAfter(event: userEvent.event, configuration: configuration)
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

    /// Disable the device's push token to tell `Connect` not to send notifications to this device.
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

    /// Determines a standard push strategy to use.
    ///
    /// - Parameters:
    ///   - response: Should come from a remote notification.
    ///   - completion: Completion handler.
    func handleNotificationResponse(_ response: ConnectNotificationResponse, completion: @escaping () -> Void) {
        // clear storage when handling UNNotificaitons
        Storage.shared.ipmModule.clearStorage()
        let standardPushStrategy = pushFactory.create(response: response,
                                                      connectAPI: connectClient)
        standardPushStrategy.handleNotification(completion: completion)
    }

    /// Determines a silent push strategy to use.
    ///
    /// - Parameters:
    ///   - userInfo: Dictionary from the push notification.
    ///   - completion: Completion handler.
    func handleNotification(userInfo: [AnyHashable: Any], completion: @escaping (Bool) -> Void) {
        let silentPushStrategy = silentPushFactory.create(userInfo: userInfo,
                                                          connectAPI: connectClient)
        silentPushStrategy.handleNotification(completion: completion)
    }
}

extension ConnectShadow: Equatable {
    static func == (lhs: ConnectShadow, rhs: ConnectShadow) -> Bool {
        return lhs.privateKey == rhs.privateKey
    }
}
