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
import ZendeskConnect

class ViewController: UIViewController {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBAction func unwind(segue:UIStoryboardSegue) { }
    
    @IBAction func login() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginController = storyboard.instantiateViewController(withIdentifier: "login-controller") as? LoginViewController else {
            return
        }
        loginController.delegate = self
        self.present(loginController, animated: true, completion: nil)
    }
    
    @IBAction func logout() {
        userLabel.text = ""
        Outbound.disableDeviceToken()
        Outbound.logout()
    }
    
    @IBAction func alias() {
        Outbound.alias("\(arc4random())")
    }
    
    @IBAction func group() {
        Outbound.identifyGroup(withId: "group-id", userId: "user-id", groupAttributes: [:], andUserAttributes: [:])
    }
    
    @IBAction func track() {
        Outbound.trackEvent("testEvent", withProperties: ["foo": "bar"])
    }
}

extension ViewController: LoginDelegate {
    func loginController(_ loginController: LoginViewController, didLogin user: String, with userDetails: UserDetails) {
        userLabel.text = user
        guard let userId = userDetails["user_id"] else {return}
        Outbound.disableDeviceToken()
        Outbound.logout()
        Outbound.identifyUser(withId: userId, attributes: userDetails)
    }
}

