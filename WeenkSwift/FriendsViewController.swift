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

class FriendsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, FriendRequstTableViewCellDelegate , FriendTableViewCellDelegate , CheckboxDialogViewDelegate{
    
    
    
    func onCheckboxPickerValueChange(_ component: DialogCheckboxViewEnum, values: TranslationDictionary, textFieldValue: String) {
        
//        SocialSystem.system.createGroup(WithGroupName: textFieldValue)
//        let group =
//
//        for (id,name) in values {
//
//            SocialSystem.system.sendGroupRequest(ToUserID: , userID: id, isChild: <#T##Bool#>)
//        }
//       
    }
    
    
    
    
    var checkBoxDialog : CheckboxDialogViewController!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func NewGroup(_ sender: Any) {
        
        let tableData = makeFriendListDialog()
        
        self.checkBoxDialog = CheckboxDialogViewController()
        self.checkBoxDialog.tableData = tableData
        self.checkBoxDialog.titleDialog = "Group Name"
        self.checkBoxDialog.componentName = DialogCheckboxViewEnum.countries
        self.checkBoxDialog.delegateDialogTableView = self
        self.checkBoxDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(self.checkBoxDialog , animated: true , completion: nil)
        
    }
    
    func makeFriendListDialog() -> [(name: String , translated: String)] {
        
        var list : [(name: String , translated: String)] = []
        for friend in SocialSystem.system.friendList {
            list.append((name: friend.id, translated: friend.name))
        }
        
        return list
    }
    
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
        
        SocialSystem.system.sendTrackRequest(ToUserID: SocialSystem.system.friendList[tappedIndexPath.row].id)
         let snackbar = TTGSnackbar(message: "Tracking Request sent to \(SocialSystem.system.friendList[tappedIndexPath.row].name!)", duration: .short)
        snackbar.show()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectendIndex = indexPath.row
        
        if indexPath.section == 0{
            performSegue(withIdentifier: "chatWithFriend", sender: self)
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatViewController{
            
            destination.friendChatWith = SocialSystem.system.friendList[tableView.indexPathForSelectedRow!.row]
        }
    }
    
}




