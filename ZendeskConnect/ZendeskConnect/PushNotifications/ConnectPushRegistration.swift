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
import UserNotifications

final class ConnectPushRegistration {

    private var attemptPrompt: Bool = true
    weak var delegate: PushRegistrationDelegate?

    func attemptAfterIdentify(configuration: Config) {
        guard
            let account = configuration.account,
            let prompt = account.prompt,
            prompt,
            account.promptEvent == nil else {
                return
        }

        requestAuthorization(account: account)
    }

    func attemptAfter(event: String, configuration: Config) {
        guard
            let account = configuration.account,
            let prompt = account.prompt,
            prompt,
            let promptEvent = account.promptEvent,
            promptEvent == event else {return}

        requestAuthorization(account: account)
    }

    private func requestAuthorization(account: AccountConfig) {

        guard let prePrompt = account.prePrompt else {
            Logger.debug("Won't show pre prompt. No prompt definition found.")
            delegate?.requestAuthorization()
            return
        }

        guard Storage.shared.pushModule.prePromptHasAcceptedPermission == false else {
            Logger.debug("Won't show pre prompt. Pre prompt has previously been displayed and accepted.")
            delegate?.requestAuthorization()
            return
        }

        guard attemptPrompt else {
            Logger.debug("Won't show pre prompt. One attempt has been made during this app lifecycle.")
            return
        }

        Logger.debug("Showing pre prompt. Will only be shown once per app run.")
        delegate?.showPrePermissionAlert(prePrompt: prePrompt)
        attemptPrompt = false
    }
}

protocol PushRegistrationDelegate: class {
    func showPrePermissionAlert(prePrompt: PrePrompt)
    func requestAuthorization()
}


class ConnectPushRegistrationDelegate: PushRegistrationDelegate {

    func showPrePermissionAlert(prePrompt: PrePrompt) {
        let alert = UIAlertController.create(withPrePrompt: prePrompt,
                                             confirmAction: { [weak self] _ in
                                                Storage.shared.pushModule.prePromptHasAcceptedPermission = true
                                                self?.requestAuthorization()

        })
        alert.show()
    }

    func requestAuthorization() {
        let app = UIApplication.shared
        let options: UNAuthorizationOptions = [.badge, .sound, .alert, .carPlay]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    app.registerForRemoteNotifications()
                }
            }
        }
    }
}
