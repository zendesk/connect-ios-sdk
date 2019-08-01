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

protocol Application {
    var applicationState: UIApplication.State { get }
}

extension UIApplication: Application {}

final class ApplicationStateOperation: Operation {

    override var isAsynchronous: Bool {
        return true
    }

    private var _isFinished: Bool = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
        get {
            return _isFinished
        }
    }

    private var _isExecuting: Bool = false
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
        get {
            return _isExecuting
        }
    }

    private let application: Application

    init(application: Application) {
        self.application = application
    }

    override func start() {
        isExecuting = true

        guard application.applicationState != .active else {
            execute()
            return
        }

        register()
    }

    @objc
    private func execute() {
        NotificationCenter.default.removeObserver(self)
        isExecuting = false
        isFinished = true
    }

    private func register() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(execute),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
}
