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

extension UIAlertController {

    /// Creates a window and adds the alert controller as root.
    /// The window is set at a window level above alerts.
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }

    typealias AlertAction = (UIAlertAction) -> Void


    /// Convienience method for creating an alert for push registration pre prompt.
    ///
    /// - Parameters:
    ///   - prePrompt: the pre prompt model.
    ///   - cancelAction: cancel action. Handles dismissing the alert.
    ///   - confirmAction: confirm action. Handles dismissing the alert.
    /// - Returns: An alert controller configured with the pre prompt model.
    static func create(withPrePrompt prePrompt: PrePrompt,
                       cancelAction: AlertAction? = nil,
                       confirmAction: AlertAction? = nil) -> UIAlertController {

        let alert = UIAlertController(title: prePrompt.title, message: prePrompt.body, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: prePrompt.noButton, style: .default, handler: { action in
            cancelAction?(action)
            alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: prePrompt.yesButton, style: .default, handler: { action in
            confirmAction?(action)
            alert.dismiss(animated: true, completion: nil)
        }))

        return alert
    }


    /// Convienience method for creating an alert for push handling pre prompt.
    /// Currently only used for push handling in app on iOS 9. 
    ///
    /// - Parameters:
    ///   - userInfo: should come from a remote notification.
    ///   - cancelAction: cancel action. Handles dismissing the alert.
    ///   - confirmAction: confirm action. Handles dismissing the alert.
    /// - Returns: An alert controller configured with the alert defined aps part of the push notification userInfo.
    static func create(withUserInfo userInfo: [AnyHashable: Any],
                       cancelAction: AlertAction? = nil,
                       confirmAction: AlertAction? = nil) -> UIAlertController? {

        guard
            let aps = userInfo["aps"] as? [String: Any] else {
                return nil
        }

        let alert = aps["alert"]

        var title: String?
        var body: String?

        if let alert = alert as? String {
            body = alert
        }

        if let alert = alert as? [String: String] {
            title = alert["title"]
            body = alert["body"]
        }

        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: SystemLocalizedString.ok, style: .default, handler: confirmAction))
        alertController.addAction(UIAlertAction(title: SystemLocalizedString.cancel, style: .cancel, handler: cancelAction))

        return alertController
    }
}
