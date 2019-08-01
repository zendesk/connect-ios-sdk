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

final class IPMViewController: UIViewController {
    private var ipm: IPMViewModel!
    private var ipmMetric: IPMMetric!

    @IBOutlet private weak var messageView: UIView! {
        didSet {
            messageView.layer.cornerRadius = 10
            messageView.backgroundColor = ipm.backgroundColor
        }
    }

    @IBOutlet private weak var avatarView: UIView! {
        didSet {
            avatarView.isHidden = ipm.logo == nil
            avatarView.layer.cornerRadius = 20
            avatarView.layer.borderWidth = 0.5
            avatarView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    @IBOutlet private weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.image = ipm.logo
        }
    }


    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = ipm.heading
            titleLabel.textColor = ipm.headingFontColor
            titleLabel.numberOfLines = 4
        }
    }

    @IBOutlet private weak var contentLabel: UILabel! {
        didSet {
            contentLabel.text = ipm.message
            contentLabel.textColor = ipm.messageFontColor
        }
    }
    @IBOutlet private weak var actionButton: UIButton! {
        didSet {
            actionButton.setTitle(ipm.buttonText, for: .normal)
            actionButton.setTitleColor(ipm.buttonTextColor, for: .normal)
            actionButton.backgroundColor = ipm.buttonBackgroundColor
        }
    }

    @IBOutlet private weak var closeButton: UIButton! {
        didSet {
            let bundle = Bundle(for: IPMViewController.self)
            let image = UIImage(named: "iconCancel", in: bundle, compatibleWith: nil)
            closeButton.setImage(image, for: .normal)
        }
    }

    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: String(describing: IPMViewController.self), bundle: Bundle(for: IPMViewController.self))
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(ipm: IPMViewModel, ipmMetric: IPMMetric) {
        self.init()
        self.ipm = ipm
        self.ipmMetric = ipmMetric

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeIpm(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeIpm(_:)))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ipmMetric.presented()
    }

    @IBAction func closeButtonAction() {
        dismiss()
    }

    @objc private func closeIpm(_ sender: Any) {
        dismiss()
    }

    func dismiss() {
        ipmMetric.dismissed()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func actionButtonAction() {
        ipmMetric.actionPressed()
        dismiss(animated: true, completion: nil)

        guard let url = ipm.action, UIApplication.shared.canOpenURL(url) else {
            Logger.debug("URL is not valid.")
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension IPMViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}
