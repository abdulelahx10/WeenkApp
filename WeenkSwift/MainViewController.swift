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
   @IBOutlet var profilebttn: UIButton!
    @IBOutlet weak var SidelMenuC: NSLayoutConstraint!
    var sideMishidden = true
    
    @IBOutlet weak var sideMtap: UIButton!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var UserPic: UIImageView!
    
    @IBOutlet var mapbutton: UIButton!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
 
    @IBOutlet var friendsbutton: UIButton!
    @IBOutlet var Scrollview: UIScrollView!
    //var storyboard = UIStoryboard(name: "Main", bundle: CFBundleGetMainBundle())
    var v1 : ViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as! ViewController
  
    var v2 : FriendsViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FriendsViewController")  as! FriendsViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
       
        UINavigationBar.appearance().barTintColor = UIColor(red:0.00, green:0.71, blue:0.83, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        
        //initiate profile bard and hid it from screen
        SidelMenuC.constant = -180
        //simple tap buton to hid the profile whenever the map tapped
        sideMtap.isHidden = true
        
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
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        SocialSystem.system.getCurrentUserData { (currentUser) in
            self.UserName.text = currentUser.name
            if(!currentUser.photoURL.isEmpty){        // check if the user have an image or not
                DispatchQueue.global().async {
                    // Create url from string address
                    guard let url = URL(string: currentUser.photoURL) else {
                        return
                    }
                    // Create data from url (You can handle exeption with try-catch)
                    guard let data = try? Data(contentsOf: url) else {
                        return
                    }
                    // Create image from data
                    guard let image = UIImage(data: data) else {
                        return
                    }
                    // Perform on UI thread
                    DispatchQueue.main.async {
                        self.UserPic.image = image
                        self.UserPic.layer.cornerRadius = (self.UserPic.frame.size.width)/2
                         self.UserPic.clipsToBounds = true
                        /* Do some stuff with your imageView */
                    }
                }
            }
        }
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
    // TODO : but change the name here
    @IBAction func EditeName(_ sender: UIButton) {
        //UserName.text
        var alert = UIAlertController(title: "Edit name", message: "Enter name:", preferredStyle: .alert)
        var textField : UITextField
        alert.addTextField { (nametext) in
            nametext.text = self.UserName.text
        }
        let changeAction = UIAlertAction(title: "Edit", style: .default) { (action) in
            SocialSystem.system.changeName(Name: alert.textFields![0].text!)
            self.UserName.text = alert.textFields![0].text!
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            /////
        }
        
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) {
            ////
        }
    }
    
    
    @IBAction func closeProfileView(_ sender: UIButton) {
        if (sideMishidden == false){
            SidelMenuC.constant = -180
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
            sideMishidden = true
            sideMtap.isHidden = true
        }
        
        
        
    }
    @IBAction func ProfileBtnClicked(_ sender: UIButton) {
        
        
                if (sideMishidden == true){
                SidelMenuC.constant = 0
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                })
        sideMishidden = false
        sideMtap.isHidden = false
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
        
        
        if(scrollView.contentOffset.y > v1.view.frame.origin.y){
            scrollView.contentOffset.y = v1.view.frame.origin.y
            
        }
        if(scrollView.contentOffset.y > v2.view.frame.origin.y){
            scrollView.contentOffset.y = v2.view.frame.origin.y
        }
        
        if (scrollView.contentOffset.x > v1.view.frame.origin.x){
            
            profilebttn.isHidden = true
            
            
            
        }else{
            profilebttn.isHidden = false

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
