//
//  ViewController.swift
//  location-test
//
//  Created by Burak Gunduz on 25.11.2019.
//  Copyright © 2019 Burak Gunduz. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    var currentLatDegrees: CLLocationDegrees? = nil
    var currentLongDegrees: CLLocationDegrees? = nil
    
    var startTime: DispatchTime = DispatchTime.now()
    var endTime: DispatchTime = DispatchTime.now()
    
    var passedData: Int = 0
    var sumData: Double = 0
    
    var desiredAddress: String = ""
    
    var isLocationUpdateLocked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        if !self.isLocationUpdateLocked {
            self.startTime = DispatchTime.now()
        }
    }

    @IBAction func startLocationBtn(_ sender: Any) {
        
        self.startTime = DispatchTime.now()
        
        if let lat = self.currentLatDegrees, let long = self.currentLongDegrees {
            self.setUsersClosestCity(lat, long: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let value = manager.location?.coordinate
        if let latitude = value?.latitude, let longitude = value?.longitude {
            self.currentLatDegrees = latitude
            self.currentLongDegrees = longitude
            
            if !self.isLocationUpdateLocked {
                if let lat = self.currentLatDegrees, let long = self.currentLongDegrees {
                    self.isLocationUpdateLocked = true
                    self.setUsersClosestCity(lat, long: long)
                }
            }
        }
    }
    
    func setUsersClosestCity(_ lat: CLLocationDegrees, long: CLLocationDegrees) {
        
        let location = CLLocation(latitude: lat, longitude: long)
        
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en")) {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if let handledPlacemarks = placemarks, handledPlacemarks.count > 0 {
                
                let pm = handledPlacemarks[0]
                
                self.endTime = DispatchTime.now()

                let nanoTime = self.endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds
                let timeInterval = Double(nanoTime) / 1_000_000_000
                
                if let street = pm.thoroughfare, let subloc = pm.subLocality, let locality = pm.locality,
                    let ads = pm.administrativeArea, let code = pm.postalCode, let count = pm.country {
                    
                    self.desiredAddress = "\(street), \(subloc), \(locality), \(ads) \(code) \(count) (lat: \(Float(lat)), long: \(Float(long))) - elapsed time: \(timeInterval)"
                }
                else if let subloc = pm.subLocality, let locality = pm.locality,
                    let ads = pm.administrativeArea, let code = pm.postalCode, let count = pm.country {

                    self.desiredAddress = "\(subloc), \(locality), \(ads) \(code) \(count) (lat: \(Float(lat)), long: \(Float(long))) - elapsed time: \(timeInterval)"
                }
                else if let locality = pm.locality,
                    let ads = pm.administrativeArea, let code = pm.postalCode, let count = pm.country {

                    self.desiredAddress = "\(locality), \(ads) \(code) \(count) (lat: \(Float(lat)), long: \(Float(long))) - elapsed time: \(timeInterval)"
                }
                else if let ads = pm.administrativeArea, let code = pm.postalCode, let count = pm.country {

                    self.desiredAddress = "\(ads) \(code) \(count) (lat: \(Float(lat)), long: \(Float(long))) - elapsed time: \(timeInterval)"
                }
                else if let count = pm.country {

                    self.desiredAddress = "\(count) (lat: \(Float(lat)), long: \(Float(long))) - elapsed time: \(timeInterval)"
                }
                
                let alert = UIAlertController(title: "Location Completed", message: self.desiredAddress, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                
                print("Problem with the data received from geocoder")
            }
        }
    }
}

