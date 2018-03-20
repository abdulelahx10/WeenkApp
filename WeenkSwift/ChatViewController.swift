///Users/abdulrahman/Desktop/Abdulllah/WeenkApp/WeenkSwift/MassageTableViewCell.swift
//  ChatViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 08/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate{
   
 
    
    @IBOutlet weak var massageTextField: UITextField!
    @IBOutlet weak var messageViewHC: NSLayoutConstraint!
    @IBOutlet weak var massageView: UIView!
    @IBOutlet weak var userChatImage: UIImageView!
    @IBOutlet weak var messageTableView: UITableView!
    
    var friendChatWith: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userChatName.text = friendChatWith?.name
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        massageTextField.delegate = self
        
        SocialSystem.system.addMessageObserver(FromChatID:(friendChatWith?.fChatId)!) {
            self.messageTableView.reloadData()
        }
        
        configureTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        SocialSystem.system.removeMessageObserver()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SocialSystem.system.messagesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let massage = tableView.dequeueReusableCell(withIdentifier: "massageCell") as? MassageTableViewCell
        
        massage?.senderName.text = SocialSystem.system.messagesList[indexPath.row].sender
        massage?.massageText.text = SocialSystem.system.messagesList[indexPath.row].message
        
        if SocialSystem.system.messagesList[indexPath.row].sender == friendChatWith?.name{
            return massage!
        }else{
            massage?.backgoundMassage.backgroundColor = UIColor.gray
            massage?.massageText.textColor = UIColor.black
        }
        return massage!
    }
    
    
    
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    @IBOutlet weak var userChatName: UILabel!
    @IBAction func SendMassage(_ sender: UIButton) {
        
        SocialSystem.system.sendMessage(ToChatID: (friendChatWith?.fChatId)!, WithTheMessage: massageTextField.text!)
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
