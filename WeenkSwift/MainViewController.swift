//
//  MainViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 20/04/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import Motion
import Firebase

class MainViewController: UIViewController , UIScrollViewDelegate {

    @IBOutlet var mapbutton: UIButton!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"

    
    @IBOutlet var signoutbttn: UIButton!
    @IBOutlet var friendsbutton: UIButton!
    @IBOutlet var Scrollview: UIScrollView!
    //var storyboard = UIStoryboard(name: "Main", bundle: CFBundleGetMainBundle())
    var v1 : ViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as! ViewController
  
    var v2 : FriendsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FriendsViewController")  as! FriendsViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        Scrollview.delegate = self
        
        self.addChildViewController(v1)
        self.Scrollview.addSubview(v1.view)
        v1.didMove(toParentViewController: self)
        
        self.addChildViewController(v2)
        self.Scrollview.addSubview(v2.view)
        v2.didMove(toParentViewController: self)
        
        
        var v2frame : CGRect = v2.view.frame
        v2frame.origin.x = self.view.frame.width
        v2.view.frame = v2frame
        
        self.Scrollview.contentSize = CGSize(width: self.view.frame.width * 2, height: self.view.frame.size.height)
        
        
        self.Scrollview.showsHorizontalScrollIndicator = true
        
        mapbutton.animate(.scale(2))
        
        
        // Do any additional setup after loading the view.
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
                    //self.nameLabel.text = self.displayName
                }
            } else {
                // user must sign in
                //self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                //self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                //ViewController.navigationController?.popToRootViewControllerAnimated(true)
                //self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)

                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func SignOut(_ sender: Any) {
        let alert = UIAlertController(title: "Sign Out", message: "Are Sure?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style:.default, handler: { (thisAlert) in
            do {
                try Auth.auth().signOut()
            } catch {
                print("unable to sign out: \(error)")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (thisAlert) in
            ///
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mapClicked(_ sender: UIButton) {
        if let image = UIImage(named:"map-2") {
            sender.setImage(UIImage(named:"map-1"), for:.normal )
            
            friendsbutton.setImage(UIImage(named: "Friends-2"), for: .normal)
            animate()
            
            Scrollview.setContentOffset(CGPoint(x: v1.view.frame.origin.x, y: v1.view.frame.origin.y), animated: true)
        }
    }
    
    @IBAction func friendsClicked(_ sender: UIButton) {
        if let image = UIImage(named:"Friends-2") {
            sender.setImage(UIImage(named:"Friends-1"), for:.normal )
            
            
            mapbutton.setImage(UIImage(named: "map-2"), for: .normal)
            animate()
            
            Scrollview.setContentOffset(CGPoint(x: v2.view.frame.origin.x, y: v2.view.frame.origin.y), animated: true)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (scrollView.contentOffset.x > v1.view.frame.origin.x){
            
            signoutbttn.isHidden = true
            
        }else{
            signoutbttn.isHidden = false

        }
        if (scrollView.contentOffset.x == v1.view.frame.origin.x){
            mapbutton.setImage(UIImage(named:"map-1"), for:.normal )
            friendsbutton.setImage(UIImage(named: "Friends-2"), for: .normal)
            
        }else if (scrollView.contentOffset.x == v2.view.frame.origin.x){
            friendsbutton.setImage(UIImage(named:"Friends-1"), for:.normal )
            mapbutton.setImage(UIImage(named: "map-2"), for: .normal)
        }
        //  animate()
    }
    
    func animate (){
        
        
        
        if mapbutton.currentImage == UIImage(named:"map-1") {
            mapbutton.animate(.scale(1.5))
            friendsbutton.animate(.scale(1))
            
        }
        
        if friendsbutton.currentImage == UIImage(named:"Friends-1"){
            friendsbutton.animate(.scale(1.5))
            mapbutton.animate(.scale(1))
        }
        
        
        
    }
    deinit {
        // set up what needs to be deinitialized when view is no longer being used
        Auth.auth().removeStateDidChangeListener(_authHandle)
        
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
