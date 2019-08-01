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

protocol KeyViewControllerDelegate: class {
    func didSelectKey(key: ZendeskKey, from viewController: UIViewController)
}

class KeyViewController: UIViewController {

    @IBOutlet weak private var keyTableView: UITableView!
    private var keys: [ZendeskKey] = []
    weak var delegate: KeyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keys = ZendeskKeyReader().readKeys()
    }
}

extension KeyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as! KeyTableViewCell
        cell.setup(zendeskKey: keys[indexPath.row])
        
        return cell
    }
}

extension KeyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectKey(key: keys[indexPath.row], from: self)
    }
}

class KeyTableViewCell: UITableViewCell {
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var urlLabel: UILabel!
    @IBOutlet weak private var environmentLabel: UILabel!
    
    func setup(zendeskKey: ZendeskKey) {
        nameLabel.text = zendeskKey.name
        urlLabel.text = zendeskKey.url
        environmentLabel.text = zendeskKey.environmentType
    }
}
