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

@objc
protocol CodeEntryProgressionControllerDelegate {
    func codeEntryProgressionController(_ codeEntryProgressionController: CodeEntryProgressionController, didComplete fields: [UITextField])
}

/// Manages the entry of the one time pairing code for test push pairing.
final class CodeEntryProgressionController: NSObject, UITextFieldDelegate {

    private let finalTextFieldTag = 4
    @IBOutlet var oneTimeCodeFields: [UITextField]!
    @IBOutlet weak var delegate: CodeEntryProgressionControllerDelegate?

    private func next(_ textField: UITextField) -> UITextField? {
        return textField.superview?.viewWithTag(textField.tag + 1) as? UITextField
    }

    private func previous(_ textField: UITextField) -> UITextField? {
        return textField.superview?.viewWithTag(textField.tag - 1) as? UITextField
    }

    private func nextResponder(for textField: UITextField, with string: String) -> UITextField? {
        return string.isEmpty ? previous(textField) : next(textField)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        guard
            string.count < 2 ||
                string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil else {
                    return false // Only allow one digit and empty string.
        }

        textField.text = string

        nextResponder(for: textField, with: string)?.becomeFirstResponder()

        if textField.tag == finalTextFieldTag {
            delegate?.codeEntryProgressionController(self, didComplete: oneTimeCodeFields)
        }

        return false
    }

    func resetFields() {
        oneTimeCodeFields.forEach { $0.text = "" }
        oneTimeCodeFields.first?.becomeFirstResponder()
    }
}
