//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Matthew Riddle on 4/05/2016.
//  Copyright © 2016 Matthew Riddle. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDetailsViewController: UITableViewController {

  var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  var placemark: CLPlacemark?

  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!

  @IBAction func done() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func cancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

