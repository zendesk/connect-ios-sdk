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

enum ConnectShadowFactory {

    static func createConnectShadow(privateKey: String,
                                    userStorageType: UserStorable.Type,
                                    configStorageType: ConfigStorable.Type,
                                    environmentStorableType: EnvironmentStorable.Type,
                                    silentPushStrategyFactoryType: SilentPushStrategyFactory.Type,
                                    currentInstance: ConnectShadow?) -> ConnectShadow? {

        // The only case where we return early is when:
        //  - connect is not nil.
        //  - privateKey is equal to connect.privateKey.
        if let currentInstance = currentInstance,
            currentInstance.privateKey == privateKey {
            return currentInstance
        }

        // From now on intializing a new instance will happen.
        let client = Client(host: URL(string: "https://\(OutboundHostDomain)")!,
                            requestDecorator: [OutboundClientDecorator(with: "\(PlatformString)/\(ConnectVersionString)"),
                                               OutboundKeyDecorator(with: privateKey),
                                               ConnectGUIDDecorator()])

        let eventQueue: Queue<Event> = Queue<Event>.create(fileName: "events.dat")
        let identifyQueue: Queue<User> = Queue<User>.create(fileName: "identities.dat")

        let connectClient = ConnectAPIClient(client: client,
                                             identifyQueue: identifyQueue,
                                             eventQueue: eventQueue)

        let userStorage = userStorageType.init()
        let configStorage = configStorageType.init()

        var environmentStorage = environmentStorableType.init()

        if let storedKey = environmentStorage.privateKey,
            storedKey != privateKey {
            userStorage.clear()
            configStorage.clear()
        }

        environmentStorage.privateKey = privateKey

        let coordinator = IPMCoordinator(connectAPI: connectClient)
        let silentPushStrategyFactory = silentPushStrategyFactoryType.init(coordinator: coordinator)

        return ConnectShadow.init(privateKey: privateKey,
                                  userStorage: userStorage,
                                  configStorage: configStorage,
                                  connectClient: connectClient,
                                  silentPushFactory: silentPushStrategyFactory)
    }
}
