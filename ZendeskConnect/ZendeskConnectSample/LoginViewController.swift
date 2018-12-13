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

typealias UserDetails = [String:String]

protocol LoginDelegate: class {
    func loginController(_ loginController: LoginViewController, didLogin user: String, with userDetails: UserDetails)
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginDelegate?
    
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBAction func login() {
        var details: UserDetails = [:]
        
        details["user_id"] = userId.text
        details["first_name"] = firstName.text
        details["last_name"] = lastName.text
        details["email"] = email.text
        details["phone_number"] = phoneNumber.text
        
        delegate?.loginController(self, didLogin: "\(firstName.text ?? "Blank first name") \(lastName.text ?? "Blank last name")", with: details)
        dismiss(animated: true, completion: nil)
    }
}

