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
import CoreLocation
import Motion

class ViewController: UIViewController , CLLocationManagerDelegate, UITableViewDelegate , UITableViewDataSource ,MGLMapViewDelegate{
   
 
    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var displayName = "Anonymous"
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var HeadingIndecator: UIButton!
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var arView: SceneLocationView!  = SceneLocationView()
    var isAR:Bool = false
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dropDownTable: UITableView!
    @IBOutlet weak var dropDownTableHC: NSLayoutConstraint!
    var dropDownIsDropped = false
    @IBOutlet weak var dropDownBtn: UIButton!
    
    var friendTrackingID : String!
    var nodeWithIDList : [String : LocationNode] = [:]
    var arMarker : [UIImage] = [UIImage(named:"marker-1")!,UIImage(named:"marker-2")!,UIImage(named:"marker-3")!,UIImage(named:"marker-4")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAuth()
        
        
        dropDownTable.delegate = self
        dropDownTable.dataSource = self
        dropDownTable.clipsToBounds = true
        dropDownTable.layer.cornerRadius = 10
        dropDownTableHC.constant = 0
    
        SocialSystem.system.addFriendObserver {
                self.dropDownTable.reloadData()
       }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.zoomLevel = 8
        mapView.setCenter(CLLocationCoordinate2D(latitude: 45, longitude: -122), animated: true)
        mapView.showsUserHeadingIndicator = true
        dropDownBtn.clipsToBounds = true
        dropDownBtn.layer.cornerRadius = 10
        dropDownBtn.titleLabel?.textAlignment = NSTextAlignment.right
        dropDownBtn.contentHorizontalAlignment = .right
    
        
        
    }

    @IBAction func indicatorClicked(_ sender: UIButton) {
        
        if mapView.userTrackingMode != .followWithHeading {
            mapView.userTrackingMode = .followWithHeading
            
            sender.animate( .rotate(90))
            sender.setImage(UIImage(named:"GPS-3"), for:.normal )
            
        } else {
            mapView.resetNorth()
            sender.animate( .rotate(-90))
            sender.setImage(UIImage(named:"GPS-1"), for:.normal )


        }
        
        
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
    
    @IBAction func ARclicked(_ sender: UIButton) {
        
        if !isAR {
            arView.run()
            mapView.zoomLevel = 12
            mapView.animate(.translate(x: 120, y: 180, z: 1),.size(CGSize(width: 100, height: 100)), .corner(radius:(50)))
            isAR = true
            HeadingIndecator.isHidden = true
            sender.setImage(#imageLiteral(resourceName: "AR-2"), for: .normal)
        }else{
            arView.pause()
            mapView.animate(.translate(x:0, y: 0, z: 1), .size(CGSize(width: 375, height: 667)), .corner(radius:(0)))
            mapView.zoomLevel = 6
            sender.setImage(#imageLiteral(resourceName: "AR-1"), for: .normal)
            HeadingIndecator.isHidden = false
            isAR = false
        }
    }
    @IBAction func toAR(_ sender: UISwitch) {
        
        
        if sender.isOn {
            
        }else{
            
        }
        
    }

    @IBAction func selectTracking(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.5) {
            if !self.dropDownIsDropped {
                self.dropDownTableHC.constant = CGFloat(46.0 * Double(SocialSystem.system.friendList.count))
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
  
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        let location = locations[locations.count - 1];
        if location.horizontalAccuracy > 0 {
            SocialSystem.system.updatePosition(lat: location.coordinate.latitude, long: location.coordinate.longitude, alti: location.altitude)
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
        
        cell?.textLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        cell?.textLabel?.textAlignment = NSTextAlignment.right
        cell?.backgroundView?.backgroundColor = UIColor(red: 0, green: 0.71, blue: 0.83, alpha: 1)
        cell?.backgroundColor = UIColor(red: 0, green: 0.71, blue: 0.83, alpha: 1)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        dropDownBtn.setTitle("     وين: \(SocialSystem.system.friendList[indexPath.row].name!)", for: .normal)
        dropDownBtn.titleLabel?.textAlignment = NSTextAlignment.right
        UIView.animate(withDuration: 0.5) {
            
            self.dropDownTableHC.constant = 0
            self.dropDownIsDropped = false
            self.view.layoutIfNeeded()
        }
        
        friendTrackingID = SocialSystem.system.friendList[indexPath.row].id
       
        SocialSystem.system.getUserPositionObserver(ForUserID: self.friendTrackingID, completion: { (pos) in
            
            let lat = Double(pos.latitude)
            let lon = Double(pos.longitude)
            let alt = Double(pos.altitude)
            if self.nodeWithIDList[self.friendTrackingID] != nil {
                self.arView.removeLocationNode(locationNode: self.nodeWithIDList[self.friendTrackingID]!)
            }

            let newNode = self.makeARmarker(latitude: lat, longitude: lon, altitude: alt)

            self.nodeWithIDList[self.friendTrackingID] = newNode
            self.arView.addLocationNodeWithConfirmedLocation(locationNode: newNode)
        })
    }
    
    func makeARmarker(latitude:Double , longitude:Double , altitude:Double) -> LocationAnnotationNode {
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude + 1.5
        )
        let annotationNode = LocationAnnotationNode(location: location, image:#imageLiteral(resourceName: "فيصل"))
        return annotationNode
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func EnableLocation(_ sender: Any) {
       
    }
    @IBAction func SignOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("unable to sign out: \(error)")
        }
    }
    
}

extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}
