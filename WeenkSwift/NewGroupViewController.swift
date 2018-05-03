//
//  NewGroupViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 23/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import TTGSnackbar
import SwiftCheckboxDialog

struct memData {
    var id:String
    var name:String
}
class NewGroupViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , CheckboxDialogViewDelegate{
   
    
    func onCheckboxPickerValueChange(_ component: DialogCheckboxViewEnum, values: TranslationDictionary) {
       
        for (id,name) in values {
            if addingChild {
                let newMem = memData(id: id, name: name)
                childMemlsit.append(newMem)
            }else{
                let newMem = memData(id: id, name: name)
                normalMemlist.append(newMem)
            }
        }
        memTable.reloadData()
    }
    
    
    var normalMemlist:[memData] = []
    var childMemlsit:[memData] = []
    var checkBoxDialog : CheckboxDialogViewController!
    var addingChild = false
    @IBOutlet weak var groupNameTextField: UITextField!
    var tableData : [(name: String , translated: String)]!
    @IBOutlet weak var memTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        SocialSystem.system.addFriendObserver {
            self.tableData = self.makeFriendListDialog()
        }
        
        memTable.delegate = self
        memTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNormal(_ sender: UIButton) {
        addingChild = false
        self.checkBoxDialog = CheckboxDialogViewController()
        self.checkBoxDialog.tableData = tableData
        self.checkBoxDialog.titleDialog = ""
        self.checkBoxDialog.componentName = DialogCheckboxViewEnum.countries
        self.checkBoxDialog.delegateDialogTableView = self
        self.checkBoxDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(self.checkBoxDialog , animated: true , completion: nil)
        
    }
    
    @IBAction func addChild(_ sender: UIButton) {
        addingChild = true
        self.checkBoxDialog = CheckboxDialogViewController()
        self.checkBoxDialog.tableData = tableData
        self.checkBoxDialog.titleDialog = ""
        self.checkBoxDialog.componentName = DialogCheckboxViewEnum.countries
        self.checkBoxDialog.delegateDialogTableView = self
        self.checkBoxDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(self.checkBoxDialog , animated: true , completion: nil)
       
    }
    func cleanTableData(tag:Int){
        
    }
    @IBAction func CreateGroup(_ sender: Any) {
        
        if normalMemlist.count + childMemlsit.count != 0 {
            let newGroupID = SocialSystem.system.createGroup(WithGroupName: groupNameTextField.text!)
            
            for friend in normalMemlist {
                SocialSystem.system.sendGroupRequest(ToUserID: friend.id, ForGroupID: newGroupID, isChild: false)
            }
            
            for child in childMemlsit {
                SocialSystem.system.sendGroupRequest(ToUserID: child.id, ForGroupID: newGroupID, isChild: true)
            }
            
            let snackbar = TTGSnackbar(message: "group \(groupNameTextField.text!) has been created", duration: .short)
            snackbar.show()
            performSegue(withIdentifier: "newGroupToFriend", sender: self)
            }
        }
       
    
    func makeFriendListDialog() -> [(name: String , translated: String)] {
        
        var list : [(name: String , translated: String)] = []
        for friend in SocialSystem.system.friendList {
            list.append((name: friend.id, translated: friend.name))
        }
        
        return list
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        switch section {
        case 0:
            return normalMemlist.count
        case 1:
            return childMemlsit.count
        default:
            return -1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        switch section {
        case 0 :
            return " "
        case 1:
            return "Child"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        switch indexPath.section {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "name")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "name")
            }
            cell?.textLabel?.text = normalMemlist[indexPath.row].name
            return cell!
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "name")
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "name")
            }
            cell?.textLabel?.text = childMemlsit[indexPath.row].name
            return cell!
        default:
            return UITableViewCell()
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

