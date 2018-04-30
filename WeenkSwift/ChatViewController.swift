///Users/abdulrahman/Desktop/Abdulllah/WeenkApp/WeenkSwift/MassageTableViewCell.swift
//  ChatViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 08/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import TTGSnackbar
class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate , TrackingRequstCellDelegate{
   
    
   
 
    
    @IBOutlet weak var massageTextField: UITextField!
    @IBOutlet weak var messageViewHC: NSLayoutConstraint!
    @IBOutlet weak var massageView: UIView!
    @IBOutlet weak var userChatImage: UIImageView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var sendMessage: UIButton!
    var label : UILabel!
    
    var friendChatWith: UserData?
    var chatWithGroup: GroupData!
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
        label = UILabel(frame: CGRect(x: 40, y: -2, width: 200, height: 50))

        let image : UIImage = UIImage(named: "user1.png")!
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        label.text = ""

        titleView.addSubview(imageView)
        titleView.addSubview(label)
        self.navigationItem.titleView = titleView

        
        // should it check if he taped on send
        if !(sendMessage.isTouchInside){
        self.hideKeyboardWhenTappedAround()
            
        }
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        massageTextField.delegate = self
        
        if friendChatWith != nil {
            label.text = friendChatWith?.name
            SocialSystem.system.addMessageObserver(FromChatID:(friendChatWith?.fChatId)!) {
                self.messageTableView.reloadData()
            }
        }else if chatWithGroup != nil {
            label.text = chatWithGroup?.groupName
            SocialSystem.system.addMessageObserver(FromChatID:(chatWithGroup?.chatId)!) {
                self.messageTableView.reloadData()
            }
        }
        configureTableView()
    }
    
    deinit {
        
        if friendChatWith != nil {
            label.text = friendChatWith?.name
            SocialSystem.system.removeMessageObserver()

        }else if chatWithGroup != nil {
            label.text = chatWithGroup?.groupName
            SocialSystem.system.removeMessageObserver()
        }
    }
    


    func acceptTracking(_ sender: TrackingRequstCell) {
        guard let tappedIndexPath = messageTableView.indexPath(for: sender) else { return}
        SocialSystem.system.acceptTrackRequest(FromUserID:(friendChatWith?.id)!)
        friendChatWith?.fIsTrackRequested = false
        messageTableView.reloadData()
        let snackbar = TTGSnackbar(message: "\(friendChatWith?.name!) Track you", duration: .short)
        snackbar.show()
        print("accpted")
    }
    @IBAction func kababMeun(_ sender: Any) {
        
        let sureAlert = UIAlertController(title: "Delete friend", message: "are you sure", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "yes", style: .default) { (action) in
            SocialSystem.system.removeFriend(WithUserID: (self.friendChatWith?.id)!)
            let snackbar = TTGSnackbar(message: " \(self.friendChatWith?.name) deleted", duration: .short)
            snackbar.show()
            self.navigationController?.popViewController(animated: true)
        }
        
        let noAction = UIAlertAction(title: "no", style: .default) { (action) in
            ///
        }
        
        sureAlert.addAction(yesAction)
        sureAlert.addAction(noAction)
        
        let alertController = UIAlertController(title: "Action Sheet", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let sendButton = UIAlertAction(title: "Send Tracking reqeust", style: .default, handler: { (action) -> Void in
            
            print("Send Tracking")
        })
        
        let  deleteButton = UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
           
           self.present(sureAlert, animated: true, completion: nil)
            print("Delete")
        })
        
    
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(sendButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func backToFriendView(){
        self.performSegue(withIdentifier: "backToFriend", sender: self)
    }
    func rejectTracking(_ sender: TrackingRequstCell) {
        SocialSystem.system.rejectTrackRequest(FromUserID: (friendChatWith?.id)!)
        friendChatWith?.fIsTrackRequested = false
        messageTableView.reloadData()
        print("rejected")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            massage?.selectionStyle = .none
            if SocialSystem.system.messagesList[indexPath.row].senderID != SocialSystem.system.CURRENT_USER_ID {
                return massage!
            }else{
                massage?.backgoundMassage.backgroundColor = UIColor.gray
                massage?.massageText.textColor = UIColor.black
            }
           
            return massage!
        case 1:
            if friendChatWith != nil{
                if (friendChatWith?.fIsTrackRequested)! {
                    let trackingRequst = tableView.dequeueReusableCell(withIdentifier: "TrackingRequstCell") as? TrackingRequstCell
                    trackingRequst?.delegate = self
                    return trackingRequst!
                }else{
                    return UITableViewCell()
                }
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
