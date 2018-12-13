/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import UIKit

protocol AdminPanelViewControllerDelegate: NSObjectProtocol {
    func adminPanelViewController(_ viewController: AdminPanelViewController, didDismissAnimated flag: Bool)
}

class AdminPanelViewController: UIViewController {

    @IBOutlet var codeEntryManager: CodeEntryProgressionController!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var popupPanel: UIView!

    var connectClient: ConnectAPI?
    var userStorage: UserReadable?

    weak var delegate: AdminPanelViewControllerDelegate?

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        // Let the delegate know that we're dismissing,
        // this is so we can clean up the window used to present this controller.
        delegate?.adminPanelViewController(self, didDismissAnimated: flag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        codeEntryManager.resetFields()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // dismiss if the user taps outside the code entry area
        guard
            let touch = touches.first,
            popupPanel.frame.contains(touch.location(in: popupPanel)) == false else {
                return
        }
        self.dismiss(animated: true, completion: nil)
    }

    private func updateSubtitle(_ success: Bool) {

        // check for failure
        guard success == false else {
            subtitle.text = "Success!";
            subtitle.textColor = .green
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }

        subtitle.text = "Pairing failed";
        subtitle.textColor = .red

        UIView.animateKeyframes(withDuration:0.6, delay: 0, options: .calculationModeCubic, animations: {
            let originalframe = self.popupPanel.frame

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1) {
                var f = originalframe
                f.origin.x += 40
                self.popupPanel.frame = f
            }
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2) {
                var f = originalframe
                f.origin.x -= 40
                self.popupPanel.frame = f
            }
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.2) {
                var f = originalframe
                f.origin.x += 20
                self.popupPanel.frame = f
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.2) {
                var f = originalframe
                f.origin.x -= 20
                self.popupPanel.frame = f
            }
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                self.popupPanel.frame = originalframe
            }
        }, completion: { _ in
            self.codeEntryManager.resetFields()
        })
    }

    private func validate(textFields: [UITextField], resultBlock: @escaping (Bool) -> Void) {
        let oneTimeCode = textFields.compactMap { return $0.text }.joined()

        guard let intValue = Int(oneTimeCode) else {
            Logger.debug("Pairing failed. Failed to validate one time code.")
            resultBlock(false)
            return
        }

        guard let deviceToken = userStorage?.readToken() else {
            Logger.debug("Pairing failed. No push device token in storage.")
            // if there is no token we may need to do trigger a register.
            UIApplication.shared.registerForRemoteNotifications()
            resultBlock(false)
            return
        }

        // do the submission of the code
        connectClient?.testSend(code: intValue, deviceToken: deviceToken) { success in
            onMain { resultBlock(success) } 
        }
    }
}

extension AdminPanelViewController: CodeEntryProgressionControllerDelegate {
    func codeEntryProgressionController(_ codeEntryProgressionController: CodeEntryProgressionController, didComplete fields: [UITextField]) {
        validate(textFields: fields) { success in
            self.updateSubtitle(success)
        }
    }
}
