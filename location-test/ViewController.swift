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
    
    var startTime: DispatchTime = DispatchTime.now()
    var endTime: DispatchTime = DispatchTime.now()
    
    var isLocationUpdateActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func startLocationBtn(_ sender: Any) {
        
        if !isLocationUpdateActive {
            self.isLocationUpdateActive = true
            self.startTime = DispatchTime.now()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let value = manager.location?.coordinate
        self.locationManager.stopUpdatingLocation()
        self.endTime = DispatchTime.now()
        
        if let latitude = value?.latitude, let longitude = value?.longitude {

            let nanoTime = self.endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            
            let alert = UIAlertController(title: "Location Manager (start-stop)", message: "First location update handled [lat: \(latitude), long: \(longitude)] then stopped. Elapsed time: \(timeInterval) sec.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (UIAlertAction) in
                self.isLocationUpdateActive = false
            })
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

