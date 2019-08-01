/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import Foundation
@testable import ZendeskConnect
import XCTest

struct MockStorage: IPMSharedStorageModule {
    private let clearedExpectation: XCTestExpectation
    private let writeIPMExpectation: XCTestExpectation

    private var _storedIPM: IPM?
    var storedIPM: IPM? {
        get {
            return _storedIPM
        }
        set {
            writeIPMExpectation.fulfill()
            _storedIPM = newValue
        }
    }

    private let _storedIdentifier: String
    var storedIdentifier: String {
        return _storedIdentifier
    }

    init(clearedExpectation: XCTestExpectation,
         writeIPMExpectation: XCTestExpectation,
         storedIPM: IPM?,
         storedIdentifier: String) {

        self.clearedExpectation = clearedExpectation
        self.writeIPMExpectation = writeIPMExpectation
        _storedIPM = storedIPM
        _storedIdentifier = storedIdentifier
    }

    func clearStorage() {
        clearedExpectation.fulfill()
    }
}
