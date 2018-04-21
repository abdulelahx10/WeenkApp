///Users/abdulrahman/Desktop/Abdulllah/WeenkApp/WeenkSwift/MassageTableViewCell.swift
//  ChatViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 08/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate , TrackingRequstCellDelegate{
   
    
   
 
    
    @IBOutlet weak var massageTextField: UITextField!
    @IBOutlet weak var messageViewHC: NSLayoutConstraint!
    @IBOutlet weak var massageView: UIView!
    @IBOutlet weak var userChatImage: UIImageView!
    @IBOutlet weak var messageTableView: UITableView!
    
    var friendChatWith: UserData?
    var chatWithGroup: GroupData!
    override func viewDidLoad() {
        super.viewDidLoad()

        messageTableView.delegate = self
        messageTableView.dataSource = self
        massageTextField.delegate = self
        
        if friendChatWith != nil {
            userChatName.text = friendChatWith?.name
            SocialSystem.system.addMessageObserver(FromChatID:(friendChatWith?.fChatId)!) {
                self.messageTableView.reloadData()
            }
        }else if chatWithGroup != nil {
            userChatName.text = chatWithGroup?.groupName
            SocialSystem.system.addMessageObserver(FromChatID:(chatWithGroup?.chatId)!) {
                self.messageTableView.reloadData()
            }
        }
        configureTableView()
    }
    
    func acceptTracking(_ sender: TrackingRequstCell) {
        guard let tappedIndexPath = messageTableView.indexPath(for: sender) else { return}
        SocialSystem.system.acceptTrackRequest(FromUserID:(friendChatWith?.id)!)
        print("accpted")
    }
    
    func rejectTracking(_ sender: TrackingRequstCell) {
        SocialSystem.system.rejectTrackRequest(FromUserID: (friendChatWith?.id)!)
        print("rejected")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        SocialSystem.system.removeMessageObserver()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return SocialSystem.system.messagesList.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch (indexPath.section) {
        case 0:
            let massage = tableView.dequeueReusableCell(withIdentifier: "massageCell") as? MassageTableViewCell
            massage?.clipsToBounds = true
            massage?.layer.cornerRadius = 10
            massage?.senderName.text = SocialSystem.system.messagesList[indexPath.row].sender
            massage?.massageText.text = SocialSystem.system.messagesList[indexPath.row].message
            
            if SocialSystem.system.messagesList[indexPath.row].senderID != SocialSystem.system.CURRENT_USER_ID {
                return massage!
            }else{
                massage?.backgoundMassage.backgroundColor = UIColor.gray
                massage?.massageText.textColor = UIColor.black
            }
            return massage!
        case 1:
            if (false) {
                let trackingRequst = tableView.dequeueReusableCell(withIdentifier: "TrackingRequstCell") as? TrackingRequstCell
                return trackingRequst!
            }else{
                return UITableViewCell()
            }
        default:
             return UITableViewCell()
        }
    }
    
    
    
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    @IBOutlet weak var userChatName: UILabel!
    @IBAction func SendMassage(_ sender: UIButton) {
        
        if friendChatWith != nil{
            SocialSystem.system.sendMessage(ToChatID: (friendChatWith?.fChatId)!, WithTheMessage: massageTextField.text!)
        }else if chatWithGroup != nil {
            SocialSystem.system.sendMessage(ToChatID: (chatWithGroup?.chatId)!, WithTheMessage: massageTextField.text!)
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.messageViewHC.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        UIView.animate(withDuration: 0.5) {
            self.messageViewHC.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
