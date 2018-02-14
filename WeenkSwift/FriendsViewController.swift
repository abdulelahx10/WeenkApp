//
//  FriendsViewController.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 12/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SocialSystem.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
    }
    deinit {
        // set up what needs to be deinitialized when view is no longer being used
        SocialSystem.system.removeFriendObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
extension FriendsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SocialSystem.system.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        if cell == nil {
            tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        }
        
        // Modify cell
        cell!.button.setTitle("Remove", for: UIControlState())
        cell!.nameLabel.text = SocialSystem.system.friendList[indexPath.row].name
        
        cell!.setFunction {
            let id = SocialSystem.system.friendList[indexPath.row].id
            SocialSystem.system.removeFriend(id!)
        }
        
        // Return cell
        return cell!
    }
    
}
