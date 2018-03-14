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
class FriendsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, FriendRequstTableViewCellDelegate , FriendTableViewCellDelegate{
    
    
   
    

    @IBOutlet weak var tableView: UITableView!
    
    var allSocialList = [socialListObj]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        
        tableView.delegate = self
        tableView.dataSource = self
        
      
        SocialSystem.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
        SocialSystem.system.addFriendRequestObserver {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        switch (section) {
        case 0:
            return SocialSystem.system.friendList.count
         
            
        case 1:
            return SocialSystem.system.userGroupdList.count
         
        
        case 2:
            return SocialSystem.system.friendRequestList.count
      
        default:
           return -1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch (indexPath.section) {
        case 0:
            
            print("type friend")
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendTableViewCell
            
            cell?.userName.text = SocialSystem.system.friendList[indexPath.row].name
            cell?.delegate = self
            
            return cell!
        
        case 1:
            return UITableViewCell()
        
        case 2:
            
            print("type friendRequst")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequstCell") as! FriendRequstTableViewCell
            
            cell.userName.text = SocialSystem.system.friendRequestList[indexPath.row].name
            cell.delegate = self
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        switch (section) {
        case 0:
            return "friends"
            
        case 1:
            return "group"
            
        case 2:
            return "friendRequst"
        default:
            return "none"
        }
    }
    func didTapAccept(_ sender: FriendRequstTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return}
        SocialSystem.system.acceptFriendRequest(FromUserID: SocialSystem.system.friendRequestList[tappedIndexPath.row].id)
        self.tableView.reloadData()
        print("accpted")
    }
    
    func didTapTrack(_ sender: FriendTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return}
        print("start Tracking \(SocialSystem.system.friendList[tappedIndexPath.row].name)")
    }
    
}




