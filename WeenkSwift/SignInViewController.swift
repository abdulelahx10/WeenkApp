//
//  SignInViewController.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 10/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseTwitterAuthUI

class SignInViewController: UIViewController {
    
    
    @IBOutlet weak var Signin: UIButton!
    @IBOutlet weak var weenkLogo: UIImageView!
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var ref: DatabaseReference!
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        let provider: [FUIAuthProvider] = [FUIGoogleAuth(), FUITwitterAuth()]
//        Signin.isHidden=true
        Signin.alpha = 0;
        
        FUIAuth.defaultAuthUI()?.providers = provider
        FUIAuth.defaultAuthUI()?.isSignInWithEmailHidden = true
        IntroAnimation()
        Signin.clipsToBounds = true
        Signin.layer.cornerRadius = 30
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // listen for changes in the authorization state
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            // check if there is a current user
            if user != nil {
                self.ref = Database.database().reference()
                self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in

                    self.ref.child("users").child(user!.uid).child("userName").setValue(user?.displayName)
                    self.ref.child("users").child(user!.uid).child("userNameLower").setValue(user?.displayName?.lowercased())
                    self.ref.child("users").child(user!.uid).child("email").setValue(user?.email)
                    if user?.photoURL != nil {
                        self.ref.child("users").child(user!.uid).child("photoURL").setValue(user?.photoURL?.absoluteString)
                    }else{
                        self.ref.child("users").child(user!.uid).child("photoURL").setValue("")
                    }
                    

                })
                self.performSegue(withIdentifier: "signedIn", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignIn(_ sender: Any) {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
        }
   
    func IntroAnimation(){
        if UIScreen.main.nativeBounds.height == 2436 {
            weenkLogo.animate(.delay(0.5),.scale(0.4), .translate(x: 0, y: -600, z: 0), .completion {
                self.Signin.isHidden = false
                self.Signin.transition(.fadeIn)
                })
            
        }else{
            weenkLogo.animate(.delay(0.5),.scale(0.4), .translate(x: 0, y: -400, z: 0), .completion {
                //                self.Signin.isHidden = false
                //                self.Signin.animate(.fadeIn, .delay(1))
                // Move our fade out code from earlier
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.Signin.alpha = 1.0
                }, completion: nil)
                
                
                })
            
        }
        
        
    }
    
    deinit {
        // set up what needs to be deinitialized when view is no longer being used
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
    /*
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     }
     */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
