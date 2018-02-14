//
//  ARViewController.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 10/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation

class ARViewController: UIViewController {

    let sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
      
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: 24.6849439, longitude: 46.5708143)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 400)
        let pinImage = UIImage(named: "location-pointer")!
        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        
        view.addSubview(sceneLocationView)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
