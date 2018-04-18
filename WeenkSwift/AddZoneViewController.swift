//
//  AddZoneViewController.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 14/04/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit
import Mapbox
class AddZoneViewController: UIViewController , MGLMapViewDelegate , UITextFieldDelegate {

    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var radiusTextField: UITextField!
    var currentZone : MGLCircleStyleLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.zoomLevel = 12
        mapView.setCenter(CLLocationCoordinate2D(latitude: 45, longitude: -122), animated: true)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(tap:)))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(singleTap)
        
        let centerScreenPoint: CGPoint = mapView.convert(mapView.centerCoordinate, toPointTo: nil)
        print("Screen center: \(centerScreenPoint) = \(mapView.center)")
        
        radiusTextField.delegate = self
        radiusTextField.text = "0"
        
    }
    
    @objc func handleSingleTap(tap: UITapGestureRecognizer) {
        if currentZone != nil{
            mapView.style?.removeLayer(currentZone)
        }
        let tapPoint: CGPoint = tap.location(in: mapView)
        let tapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: nil)
        print("You tapped at: \(tapCoordinate.latitude), \(tapCoordinate.longitude)")
        let center = tapCoordinate
        mapView.setCenter(center, animated: true)
        let radiusMeters = Double(radiusTextField.text!)
        
    
        let point = MGLPointAnnotation()
        point.coordinate = center
       let source = MGLShapeSource(identifier: "circle", shape: point, options: nil)
        if currentZone == nil{
            mapView.style?.addSource(source)
        }
        let zone = MGLCircleStyleLayer(identifier: "circle", source: source)
        let radiusPoints = radiusMeters! / mapView.metersPerPoint(atLatitude: center.latitude)
        zone.circleRadius = MGLStyleValue(rawValue: NSNumber(value: radiusPoints))
        zone.circleColor = MGLStyleValue(rawValue: UIColor.cyan)
        zone.circleOpacity = MGLStyleValue(rawValue: 0.5)
        currentZone = zone
        mapView.style?.addLayer(zone)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
