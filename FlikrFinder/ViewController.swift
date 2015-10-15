//
//  ViewController.swift
//  FlikrFinder
//
//  Created by Michael Johnston on 07.10.2015.
//  Copyright © 2015 Metafeat Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var nameSearchTextField: UITextField!
  @IBOutlet weak var latitudeSearchTextField: UITextField!
  @IBOutlet weak var longitudeSearchTextField: UITextField!
  @IBOutlet weak var imageTitle: UILabel!



  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func performPhraseSeach(sender: UIButton) {
  }

  @IBAction func performGeoSearch(sender: UIButton) {
  }
}

