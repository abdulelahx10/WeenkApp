//
//  FriendsViewController.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 12/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import TTGSnackbar
import SwiftCheckboxDialog

class FriendsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, FriendRequstTableViewCellDelegate , FriendTableViewCellDelegate,GroupRequstTableViewCellDelegate{
    


    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func NewGroup(_ sender: Any) {
        

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        
        tableView.delegate = self
        tableView.dataSource = self
        
      
        
        
        SocialSystem.system.addFriendRequestObserver {
            self.tableView.reloadData()
        }
        
        SocialSystem.system.addGroupRequestObserver {
            self.tableView.reloadData()
        }
        
        SocialSystem.system.addUserGroupsObserver {
            self.tableView.reloadData()
        }
        
        
    }
    deinit {
        // set up what needs to be deinitialized when view is no longer being used
        SocialSystem.system.removeFriendObserver()
        SocialSystem.system.removeRequestObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        switch (section) {
        case 0:
            return SocialSystem.system.friendList.count
         
        case 1:
            return SocialSystem.system.userGroupdList.count
         
        case 2:
            return SocialSystem.system.friendRequestList.count
        case 3:
            return SocialSystem.system.groupRequestList.count
        default:
           return -1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch (indexPath.section) {
        case 0:
            
            print("type friend")
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendTableViewCell
            
            if !SocialSystem.system.friendList.indices.contains(indexPath.row){
                return UITableViewCell()
            }
            cell?.userName.text = SocialSystem.system.friendList[indexPath.row].name
            cell?.delegate = self
            if SocialSystem.system.friendList[indexPath.row].fIsTrackRequested {
                cell?.trackBtn.isEnabled = false
            }
            return cell!
        
        case 1:
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendTableViewCell
            
            if !SocialSystem.system.userGroupdList.indices.contains(indexPath.row){
                return UITableViewCell()
            }
            cell?.userName.text = SocialSystem.system.userGroupdList[indexPath.row].groupName
            cell?.trackBtn.isEnabled = false
            cell?.trackBtn.isHidden = true
            cell?.delegate = self
            
            return cell!
        case 2:
            
            
            print("type friendRequst")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequstCell") as? FriendRequstTableViewCell
            
            if !SocialSystem.system.friendRequestList.indices.contains(indexPath.row){
                return UITableViewCell()
            }
            cell?.userName.text = SocialSystem.system.friendRequestList[indexPath.row].name
            cell?.delegate = self
            
            return cell!
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupRequstCell") as? GroupRequstTableViewCell
            
            if !SocialSystem.system.groupRequestList.indices.contains(indexPath.row){
                return UITableViewCell()
            }
            cell?.groupName.text = " \(SocialSystem.system.groupRequestList[indexPath.row].groupName)"
            cell?.delegate = self
            
            return cell!
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
            
        case 3:
            return "Group Requst"
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
    
    func didTapAcceptGroup(_ sender: GroupRequstTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return}
        SocialSystem.system.acceptGroupRequest(FromGroupID: SocialSystem.system.groupRequestList[tappedIndexPath.row].id)
        self.tableView.reloadData()
        print("group accpted")
    }
    
    func didTapTrack(_ sender: FriendTableViewCell) {
        
       
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return}
        
        SocialSystem.system.sendTrackRequest(ToUserID: SocialSystem.system.friendList[tappedIndexPath.row].id)
        
        let snackbar = TTGSnackbar(message: "Tracking Request sent to \(SocialSystem.system.friendList[tappedIndexPath.row].name!)", duration: .short)
        snackbar.show()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if indexPath.section == 0{
            performSegue(withIdentifier: "chatWithFriend", sender: self)
        }else if indexPath.section == 1 {
             performSegue(withIdentifier: "chatWithFriend", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatViewController{
            if tableView.indexPathForSelectedRow?.section == 0 {
                destination.friendChatWith = SocialSystem.system.friendList[tableView.indexPathForSelectedRow!.row]
                destination.chatWithGroup = nil
            }else if tableView.indexPathForSelectedRow?.section == 1 {
                destination.chatWithGroup = SocialSystem.system.userGroupdList[tableView.indexPathForSelectedRow!.row]
                destination.friendChatWith = nil
            }
        }
    }
    
}




