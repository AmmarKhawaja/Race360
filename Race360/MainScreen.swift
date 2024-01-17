//
//  MainScreen.swift
//  Race360
//
//  Created by Ammar Khawaja on 1/3/24.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase

let r_user = r.child("users").child(USERID)

class MainScreen: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapV: MKMapView!
    @IBOutlet weak var userCurrSpeed: UILabel!
    @IBOutlet weak var userCurrSpeedBar: UIProgressView!
    @IBOutlet weak var userSpeedToday: UILabel!
    @IBOutlet weak var userSpeedAll: UILabel!
    let manager = CLLocationManager()
    
    let date = Date()
    let formatter = DateFormatter()
    var topSpeedDaily = 0
    var topSpeedAll = 0

    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        formatter.dateFormat = "dd-MM-yyyy"
        let currDate = formatter.string(from: date)
        r_user.child("speed").child(currDate).child("spe").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.topSpeedDaily = snapshot.value as! Int
            }
            self.userSpeedToday.text = "Daily: \(self.topSpeedDaily)"
        }
        r_user.child("speed").child("alltime").child("spe").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.topSpeedAll = snapshot.value as! Int
            }
            self.userSpeedAll.text = "All-Time: \(self.topSpeedAll)"
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapV.setRegion(region, animated: true)
            mapV.showsUserLocation = true
            var currSpeed = Int((manager.location?.speed ?? 0.0) * 2.237 * 1.05)
            if currSpeed > 999 {
                currSpeed = 999
            }else if currSpeed < 0 {
                currSpeed = 0
            }
            userCurrSpeed.text = "\(currSpeed)"
            userCurrSpeedBar.setProgress(sqrtf(Float(currSpeed))/20, animated: true)
            let currDate = formatter.string(from: date)
            if currSpeed > topSpeedDaily {
                // Hopefully there is no issue with this executing before topSpeedDaily is retrieved.
                topSpeedDaily = currSpeed
                userSpeedToday.text = "Daily: \(self.topSpeedDaily)"
                r_user.child("speed").child(currDate).child("spe").setValue(topSpeedDaily)
                r_user.child("speed").child(currDate).child("loc").setValue(String(location.coordinate.latitude) + "," + String(location.coordinate.longitude))
            }
            if currSpeed > topSpeedAll {
                topSpeedAll = currSpeed
                userSpeedAll.text = "All-Time: \(self.topSpeedAll)"
                r_user.child("speed").child("alltime").child("spe").setValue(topSpeedDaily)
                r_user.child("speed").child("alltime").child("loc").setValue(String(location.coordinate.latitude) + "," + String(location.coordinate.longitude))
            }
        }
    }
}
