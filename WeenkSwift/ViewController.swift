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

class ViewController: UIViewController , CLLocationManagerDelegate, UITableViewDelegate , UITableViewDataSource{
   
 
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var arView: SceneLocationView! = SceneLocationView()
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dropDownTable: UITableView!
    @IBOutlet weak var dropDownTableHC: NSLayoutConstraint!
    var dropDownIsDropped = false
    @IBOutlet weak var dropDownBtn: UIButton!
    
    var friendTrackingID : String!
    var nodeWithIDList : [String : LocationNode] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        
        
        dropDownTable.delegate = self
        dropDownTable.dataSource = self
        dropDownTableHC.constant = 0
        
        arView.run()
        
        
        
        SocialSystem.system.addFriendObserver {
                self.dropDownTable.reloadData()

       }
        
   
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        
        dropDownBtn.clipsToBounds = true
        dropDownBtn.layer.cornerRadius = 10
     
       
        
       
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
    
    
    @IBAction func selectTracking(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5) {
            if !self.dropDownIsDropped {
                
                self.dropDownTableHC.constant = CGFloat(44.0 * 5.0)
                self.dropDownIsDropped = true
            }else{
                
                self.dropDownTableHC.constant = 0
                self.dropDownIsDropped = false
                
            }
           
            self.view.layoutIfNeeded()
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
            SocialSystem.system.updatePosition(lat: "\(location.coordinate.latitude)", long: "\(location.coordinate.longitude)", alti: "\(location.altitude)")
            print(location.altitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SocialSystem.system.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "dropCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "dropCell")
        }
        if SocialSystem.system.friendList.count != 0 {
            cell?.textLabel?.text = SocialSystem.system.friendList[indexPath.row].name
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        dropDownBtn.setTitle("    Tracking: \(SocialSystem.system.friendList[indexPath.row].name!)", for: .normal)
        UIView.animate(withDuration: 0.5) {
            
            self.dropDownTableHC.constant = 0
            self.dropDownIsDropped = false
            self.view.layoutIfNeeded()
        }
        
        friendTrackingID = SocialSystem.system.friendList[indexPath.row].id
        

        
        SocialSystem.system.getUserPositionObserver(ForUserID: self.friendTrackingID, completion: { (pos) in
            
            if self.nodeWithIDList[self.friendTrackingID] != nil {
                self.arView.removeLocationNode(locationNode: self.nodeWithIDList[self.friendTrackingID]!)
            }
            
            var newNode = self.makeARmarker(latitude: pos.latitude, longitude: pos.longitude , altitude: pos.altitude)
            
            self.nodeWithIDList[self.friendTrackingID] = newNode
            self.arView.addLocationNodeWithConfirmedLocation(locationNode: newNode)
            
        })
    }
    
    func makeARmarker(latitude:String , longitude:String , altitude:String) -> LocationAnnotationNode {
        
        var lat = Double(latitude)
        var lon = Double(longitude)
        var alt = Double(altitude)
        var coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
        var location = CLLocation(coordinate: coordinate, altitude: alt!)
        var image = UIImage(named: "location-pointer")!
        var annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.scaleRelativeToDistance = true
        
        return annotationNode
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

