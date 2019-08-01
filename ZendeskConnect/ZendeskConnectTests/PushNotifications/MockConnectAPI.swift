/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import XCTest
@testable import ZendeskConnect

final class MockConnectAPI: ConnectAPI {
    var autoFlush: Bool = true

    func flush() {
        
    }

    func identifyUser(_ user: User) {

    }

    func track(_ event: Event) {

    }

    func clear() {}


    private(set) var tracked = false
    private(set) var received = false
    private(set) var opened = false

    func register(_ token: Data, for userId: String) {}

    func disable(_ token: Data, for userId: String) {}

    func flush(_ eventQueue: Queue<Event>) {}

    func flush(_ identifyQueue: Queue<User>) {}

    func track(uninstall: UninstallTracker, completion: PushProviderCompletion?) {
        tracked = true
        completion?(true)
    }

    func send(received metric: PushBasicMetric, completion: PushProviderCompletion?) {
        received = true
    }

    func send(opened metric: PushBasicMetric, completion: PushProviderCompletion?) {
        opened = true
    }

    func testSend(code: Int, deviceToken: Data, completion: @escaping (Bool) -> Void) {}
}
