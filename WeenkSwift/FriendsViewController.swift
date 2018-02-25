//
//  FriendsViewController.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 12/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

struct socialListObj {
    
    let type:String
    let list:[Any]
}
class FriendsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var allSocialList = [socialListObj]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        SocialSystem.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var friends = socialListObj(type: "friends", list: SocialSystem.system.friendList)
        var groups = socialListObj(type: "group", list: SocialSystem.system.userGroupdList)
        var friendRequsts = socialListObj(type: "friendRequst", list: SocialSystem.system.friendRequestList)
        
        allSocialList.append(groups)
        allSocialList.append(friends)
        allSocialList.append(friendRequsts)
        
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allSocialList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSocialList[section].list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create cell
        

        if allSocialList[indexPath.section].type == "friend" {
            
            var cellUser:UserData = allSocialList[indexPath.section].list[indexPath.row] as! UserData
            var cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
            if cell == nil {
                tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
            }
            
            // Modify cell
            cell!.button.setTitle("track", for: UIControlState())
            cell!.nameLabel.text = cellUser.name
            
            
            cell!.setFunction {
                let id = SocialSystem.system.friendList[indexPath.row].id
                SocialSystem.system.removeFriend(id!)
            }
            
            // Return cell
            return cell!
        }else if allSocialList[indexPath.section].type == "group"{
            
        }else if allSocialList[indexPath.section].type == "friendRequst"{
            

        // Modify cell
        cell!.button.setTitle("Remove", for: UIControlState())
        cell!.nameLabel.text = SocialSystem.system.friendList[indexPath.row].name
        
        cell!.setFunction {
            let id = SocialSystem.system.friendList[indexPath.row].id
            SocialSystem.system.removeFriend(WithUserID: id!)

        }
        
        
        return UITableViewCell()
    }

}


