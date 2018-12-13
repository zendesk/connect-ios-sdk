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


fileprivate let TouchesRequired = 4
#if DEBUG
fileprivate let PressDuration: TimeInterval = 4
#else
fileprivate let PressDuration: TimeInterval = 8
#endif


/// Manages presenting the admin panel from a
final class AdminPresenter: NSObject, AdminPanelViewControllerDelegate {

    private var userStorage: UserStorable
    private var connectClient: ConnectAPI

    init(userStorage: UserStorable, connectClient: ConnectAPI) {
        self.userStorage = userStorage
        self.connectClient = connectClient
    }

    /// Stored while dispalying an AdbinPanelViewController. Set to nil after panel is dismissed.
    private static var window: UIWindow?
    private static let gesture = UILongPressGestureRecognizer(target: nil, action: nil)

    static func addGestureTarget(_ target: Any, action: Selector) {
        // remove previous target and action
        gesture.removeTarget(nil, action: nil)
        gesture.addTarget(target, action: action)
        gesture.cancelsTouchesInView = true
        gesture.numberOfTouchesRequired = TouchesRequired
        gesture.minimumPressDuration = PressDuration

        // Key window may have changed, ensure gesture isn't on any other window.
        let app = UIApplication.shared
        app.windows.forEach { $0.removeGestureRecognizer(AdminPresenter.gesture) }

        if app.keyWindow == nil { // if being called from app startup there is a race condition for key window to be non null. 
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { app.keyWindow?.addGestureRecognizer(gesture) }
        } else {
            app.keyWindow?.addGestureRecognizer(gesture)
        }
    }

    @objc
    func present(_  gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }

        let storyboard = UIStoryboard.init(name: "AdminPanel", bundle: Bundle(for: type(of: self)))
        guard let adminVC = storyboard.instantiateInitialViewController() as? AdminPanelViewController else {
            return
        }

        // set up the delegat so we can dismiss on valid code entry.
        adminVC.delegate = self

        adminVC.connectClient = connectClient
        adminVC.userStorage = userStorage

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isOpaque = false
        window.windowLevel = UIWindow.Level.alert + 1
        window.makeKeyAndVisible()

        // Set a blank view controller as root so we can present from it and get animations for free.
        window.rootViewController = UIViewController(nibName: nil, bundle: nil)
        window.rootViewController?.present(adminVC, animated: true, completion: nil)

        // keep the windo around so it isn't dealocated.
        AdminPresenter.window = window
    }

    func adminPanelViewController(_ viewController: AdminPanelViewController, didDismissAnimated flag: Bool) {
        // Give the view controller time to animate off screen.
        // Then resing key and hide so the host app is passed touch events.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            AdminPresenter.window?.resignKey()
            AdminPresenter.window?.isHidden = true
            AdminPresenter.window = nil
        }
    }
}
