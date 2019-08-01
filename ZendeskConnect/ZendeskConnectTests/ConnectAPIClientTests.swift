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

final class ConnectAPIClientTests: XCTestCase {
    private let metric = PushBasicMetric(_oid: "push-pie")
    private let noIDMetric = PushBasicMetric(_oid: nil)
    private let tracker = UninstallTracker(i: "tracker-pie", revoked: false)
    private let noIDTracker = UninstallTracker(i: nil, revoked: nil)

    private func setupConnectAPIClient(isSuccessful: Bool) -> ConnectAPIClient {
        let client = Client(host: URL(string: "host.pie")!)
        let metricsProvider = MockMetricsProvider(with: client, successfulResult: isSuccessful)
        let eventQueue: Queue<Event> = Queue<Event>.create(fileName: "")
        let identifyQueue: Queue<User> = Queue<User>.create(fileName: "")
        return ConnectAPIClient(client: client,
                                identifyQueue: identifyQueue,
                                eventQueue: eventQueue,
                                dispatchGroup: DispatchGroup(),
                                metricsProvider: metricsProvider)
    }

    func testMetricUninstallTrackerSuccess() {
        let api = setupConnectAPIClient(isSuccessful: true)

        api.track(uninstall: tracker) { result in
            XCTAssertTrue(result)
        }
    }

    func testMetricUninstallTrackerNoIDSuccess() {
        let api = setupConnectAPIClient(isSuccessful: true)

        api.track(uninstall: noIDTracker) { result in
            XCTAssertTrue(result)
        }
    }

    func testMetricOpenedSuccess() {
        let api = setupConnectAPIClient(isSuccessful: true)

        api.send(opened: metric) { result in
            XCTAssertTrue(result)
        }
    }

    func testMetricOpenedNoIDSuccess() {
        let api = setupConnectAPIClient(isSuccessful: true)

        api.send(opened: noIDMetric) { result in
            XCTAssertTrue(result)
        }
    }

    func testMetricReceivedSuccess() {
        let api = setupConnectAPIClient(isSuccessful: true)

        api.send(received: metric) { result in
            XCTAssertTrue(result)
        }
    }

    func testMetricReceivedNoIDSuccess() {
        let api = setupConnectAPIClient(isSuccessful: true)

        api.send(received: noIDMetric) { result in
            XCTAssertTrue(result)
        }
    }

    func testMetricUninstallTrackerFailure() {
        let api = setupConnectAPIClient(isSuccessful: false)

        api.track(uninstall: tracker) { result in
            XCTAssertFalse(result)
        }
    }

    func testMetricOpenedFailure() {
        let api = setupConnectAPIClient(isSuccessful: false)

        api.send(opened: metric) { result in
            XCTAssertFalse(result)
        }
    }

    func testMetricReceivedFailure() {
        let api = setupConnectAPIClient(isSuccessful: false)

        api.send(received: metric) { result in
            XCTAssertFalse(result)
        }
    }
}
