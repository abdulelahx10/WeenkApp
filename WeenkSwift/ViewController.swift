//
//  ViewController.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 03/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import Firebase
import Mapbox


class ViewController: UIViewController {

    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        

    }
    
    func configureAuth() {
        
        // listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            // check if there is a current user
            if let activeUser = user {
                // check if the current app user is the current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                    let name = user!.displayName
                    //let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name!
                    self.nameLabel.text = self.displayName
                }
            } else {
                // user must sign in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    deinit {
        // set up what needs to be deinitialized when view is no longer being used
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    @IBAction func AR(_ sender: Any) {
        self.performSegue(withIdentifier: "AR", sender: self)
    }
    
}

