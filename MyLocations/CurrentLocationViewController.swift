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
  let geocoder = CLGeocoder()

  var timer: NSTimer?
  var location: CLLocation?
  var updatingLocation = false
  var placemark: CLPlacemark?
  var performingReverseGeocoding = false

  var lastLocationError: NSError?
  var lastGeocodingError: NSError?

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

    if updatingLocation {
      stopLocationManager()
    } else {
      location = nil
      lastLocationError = nil
      placemark = nil
      lastGeocodingError = nil
      startLocationManager()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLabels()
    configureGetButton()
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
      addressLabel.text = placemarkMessage
    } else {
      latitudeLabel.text = ""
      longitudeLabel.text = ""
      addressLabel.text = ""
      tagButton.hidden = true

    }
    messageLabel.text = statusMessage
  }

  func stringFromPlacemark(placemark: CLPlacemark) -> String {
    var line1 = ""

    if let s = placemark.subThoroughfare {
      line1 += s + " "
    }

    if let s = placemark.thoroughfare {
      line1 += s
    }

    var line2 = ""

    if let s = placemark.locality {
      line2 += s + " "
    }

    if let s = placemark.administrativeArea {
      line2 += s + " "
    }

    if let s = placemark.postalCode {
      line2 += s
    }

    return line1 + "\n" + line2
  }

  var placemarkMessage: String {
    get {
      if location == nil {
        return ""
      }
      if let placemark = placemark {
        return stringFromPlacemark(placemark)
      } else if performingReverseGeocoding {
        return "Searching for Address..."
      } else if lastGeocodingError != nil {
        return "Error finding Address"
      } else {
        return "No Address Found"
      }
    }
  }

  var statusMessage: String {
    get {
      if location != nil {
        return ""
      }
      if let error = lastLocationError {
        if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
          return "Location Services Disabled"
        } else {
          return "Error Getting Location"
        }
      } else if !CLLocationManager.locationServicesEnabled() {
        return "Location Services Disabled"
      } else if updatingLocation {
        return "Searching..."
      } else {
        return "Tap 'Get My Location' to Start"
      }
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
    configureGetButton()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")

    if newLocation.timestamp.timeIntervalSinceNow < -5
      || newLocation.horizontalAccuracy < 0 {
      return
    }

    var distance = CLLocationDistance(DBL_MAX)
    if let location = location {
      distance = newLocation.distanceFromLocation(location)
    }

    if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {

      lastLocationError = nil
      location = newLocation
      updateLabels()

      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        print("Stopping location retrieval. Reached desired accuracy")
        stopLocationManager()
        configureGetButton()
      }
      if distance > 0 {
        performingReverseGeocoding = false
      }
      performReverseGeocoding(newLocation)
    } else if distance < 1.0 {
      let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)

      if timeInterval > 10 {
        print("We haven't moved for over 10 seconds, not going to look for another location")
        stopLocationManager()
        updateLabels()
        configureGetButton()
      }
    }
  }

  func performReverseGeocoding(location: CLLocation) {
    if performingReverseGeocoding {
      return
    }
    print("Performing reverse geocoding")
    performingReverseGeocoding = true

    geocoder.reverseGeocodeLocation(location, completionHandler: {
      placemarks, error in
      print("Found \(placemarks), error: \(error)")
      self.lastGeocodingError = error
      if error == nil, let p = placemarks where !p.isEmpty {
        self.placemark = p.last!
      } else {
        self.placemark = nil
      }

      self.performingReverseGeocoding = false
      self.updateLabels()
    })
  }

  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "Location Services Disabled",
                                  message: "Please enable location services for this app in Settngs.",
                                  preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

    alert.addAction(okAction)

    presentViewController(alert, animated: true, completion: nil)
  }

  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      print("Starting location manager")
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      updatingLocation = true

      timer = NSTimer.scheduledTimerWithTimeInterval(60,
                                                     target: self,
                                                     selector: #selector(CurrentLocationViewController.didTimeOut),
                                                     userInfo: nil,
                                                     repeats: false)
    }
  }

  func stopLocationManager() {
    if updatingLocation {
      if let timer = timer {
        timer.invalidate()
      }
      print("Stopping location manager")
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updatingLocation = false
    }
  }

  func configureGetButton() {
    if updatingLocation {
      getButton.setTitle("Stop", forState: .Normal)
    } else {
      getButton.setTitle("Get My Location", forState: .Normal)
    }
  }

  func didTimeOut() {
    print("App timed out trying to find location")

    if location == nil {
      stopLocationManager()
      lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)

      updateLabels()
      configureGetButton()
    }
  }
}

