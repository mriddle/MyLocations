//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Matthew Riddle on 4/05/2016.
//  Copyright © 2016 Matthew Riddle. All rights reserved.
//

import UIKit

class CurrentLocationViewController: UIViewController {

  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var getButton: UIButton!
  
  
  @IBAction func getLocation() {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

