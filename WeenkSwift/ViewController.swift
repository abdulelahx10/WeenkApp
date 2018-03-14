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
import ARCL
import Motion
import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate{

    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var arView: SceneLocationView! = SceneLocationView()
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        
        

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

    @IBAction func toAR(_ sender: UISwitch) {
        
        
        if sender.isOn {
            arView.run()
            
            mapView.zoomLevel = 12
            mapView.animate(.translate(x: 120, y: 180, z: 1), .scale(x:0.2668,y:0.15,z:1), .corner(radius:(187.5  * 1.4)))
        }else{
            arView.pause()
            mapView.animate(.translate(x:0, y: 0, z: 1), .scale(x:1,y:1,z:1), .corner(radius:(0)))
            mapView.zoomLevel = 6
        }
        
    }
    
    deinit {
        // set up what needs to be deinitialized when view is no longer being used
        Auth.auth().removeStateDidChangeListener(_authHandle)
        arView.pause()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1];
        if location.horizontalAccuracy > 0 {
            
            //store user location data
            //user.lat = location.coordinate.latitude
            //user.lon = location.coordinate.longitude
            
           
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
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
    
}

