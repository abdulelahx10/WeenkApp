///Users/abdulrahman/Desktop/Abdulllah/WeenkApp/WeenkSwift/MassageTableViewCell.swift
//  ChatViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 08/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return SocialSystem.system.messagesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let massage = tableView.dequeueReusableCell(withIdentifier: "massageCell") as? MassageTableViewCell
        
        massage?.senderName.text = SocialSystem.system.messagesList[indexPath.row].sender
        massage?.massageText.text = SocialSystem.system.messagesList[indexPath.row].message
        
        
        return massage!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func configureTableView(){
        
    }

    @IBOutlet weak var userChatName: UILabel!
    @IBAction func SendMassage(_ sender: Any) {
        
    }
    
    @IBOutlet weak var massageTextField: UITextField!
    @IBOutlet weak var massageView: UIView!
    @IBOutlet weak var userChatImage: UIImageView!
    
    var friendChatWith: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userChatName.text = friendChatWith?.name
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
