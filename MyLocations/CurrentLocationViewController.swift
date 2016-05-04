//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Matthew Riddle on 4/05/2016.
//  Copyright © 2016 Matthew Riddle. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!

  let locationManager = CLLocationManager()
  var location: CLLocation?

  var updatingLocation = false
  var lastLocationError: NSError?

  @IBAction func getLocation() {
    let authStatus = CLLocationManager.authorizationStatus()
    
    if authStatus == .NotDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    if authStatus == .Denied || authStatus == .Restricted {
      showLocationServicesDeniedAlert()
      return
    }
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func updateLabels() {
    if let location = location {
      latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
      longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
      tagButton.hidden = false
      messageLabel.text = ""
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.hidden = true
      messageLabel.text = "Tap 'Get My Location' to Start"
    }
  }

  // MARK: - CLLocationManagerDeleagate
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError \(error)")

    if error.code == CLError.LocationUnknown.rawValue {
      return
    }

    lastLocationError = error

    stopLocationManager()
    updateLabels()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")

    location = newLocation
    updateLabels()
  }

  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled",
                                  message: "Please enable location services for this app in Settngs.",
                                  preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

    alert.addAction(okAction)

    presentViewController(alert, animated: true, completion: nil)
  }

  func stopLocationManager() {
    if updatingLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }


}

