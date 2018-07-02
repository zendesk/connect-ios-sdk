//
//  LoginViewController.swift
//  ConnectSample
//
//  Created by Alan Egan on 19/06/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

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

