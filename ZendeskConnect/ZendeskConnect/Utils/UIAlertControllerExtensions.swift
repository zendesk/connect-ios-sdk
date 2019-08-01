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

    /// Creates a `UIWindow` and adds a `UIViewController` as root.
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


    /// Convenience method for creating an alert for push registration pre prompt.
    ///
    /// - Parameters:
    ///   - prePrompt: The `PrePrompt` model.
    ///   - cancelAction: Cancel action. Handles dismissing the alert.
    ///   - confirmAction: Confirm action. Handles dismissing the alert.
    /// - Returns: A `UIAlertController` configured with the `PrePrompt` model.
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
}
