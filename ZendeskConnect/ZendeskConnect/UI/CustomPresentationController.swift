/*
 *  Copyright (c) 2019 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import UIKit

final class CustomPresentationController: UIPresentationController {
    private let dimmingView: UIView
    private let dimmingViewVisibleAlpha: CGFloat
    private let dimmingViewHiddenAlpha: CGFloat = 0.0

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         dimmingViewVisibleAlpha: CGFloat = 0.4) {

        dimmingView = UIView()
        dimmingView.backgroundColor = .black
        dimmingView.alpha = dimmingViewHiddenAlpha
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.dimmingViewVisibleAlpha = dimmingViewVisibleAlpha
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        dimmingView.frame = containerView.frame
        containerView.addSubview(dimmingView)

        let coordinator = presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = self.dimmingViewVisibleAlpha
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        let coordinator = presentedViewController.transitionCoordinator
        coordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = self.dimmingViewHiddenAlpha
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            IPMWindow.resignKeyAndHide()
        }
    }
}
