//
//  AddFriendViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 23/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UISearchBarDelegate{
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SocialSystem.system.searchedUsersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell") as! addFriendTableViewCell
        cell.userName.text = SocialSystem.system.searchedUsersList[indexPath.row].name
        
        return cell
    }
    

    @IBAction func onTextChange(_ sender: UITextField) {
      
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textChange")
        SocialSystem.system.SearchUsers(WithName: searchText) {
            self.tableView.reloadData()
            print("updated")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = SocialSystem.system.searchedUsersList[indexPath.row]
        SocialSystem.system.sendFriendRequest(ToUserID: selectedUser.id)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    

    
}
