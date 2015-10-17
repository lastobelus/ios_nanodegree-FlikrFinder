//
//  ViewController.swift
//  FlikrFinder
//
//  Created by Michael Johnston on 07.10.2015.
//  Copyright © 2015 Metafeat Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
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

  // MARK: Actions
  @IBAction func performPhraseSeach(sender: UIButton) {
    let urlSession = NSURLSession.sharedSession()
    let api = FlikrAPI()
    let request = api.photos_search_request("baby asian elephants")

    print("made request: \(request.URL)")
    let dataTask = urlSession.dataTaskWithRequest(request, completionHandler: api.handleResult(request.URL!.absoluteString, completion: { json in

      // check for photos key
      guard let photosResult = json[FlikrAPI.Keys.PhotosSearchResult] as? [String:AnyObject] else {
        print("Cannot find keys 'photos' in \(json)")
        return
      }

      // get total photos
      guard let total = (photosResult["total"] as? NSString)?.integerValue else {
        print("Cannot find key 'total' in \(photosResult)")
        return
      }


      if total > 0 {
        /* GUARD: Is the "photo" key in photosDictionary? */
        guard let photos = photosResult["photo"] as? [[String: AnyObject]] else {
          print("Cannot find key 'photo' in \(photosResult)")
          return
        }


        // get total photos
        guard let perpage = (photosResult["perpage"] as? NSNumber) else {
          print("Cannot find key 'perpage' in \(photosResult)")
          return
        }

        print("total: \(total)  perpage: \(perpage)  count: \(photos.count)")

        //      let total = photosResult["total"] as! UInt32
        //      print("total: \(total)")
        //      let photos = photosResult["photo"] as! [[String:AnyObject]]
        let ix = Int(arc4random_uniform(UInt32(photos.count)))
        let choice = photos[ix] as [String:AnyObject]

        let photoTitle = choice["title"] as? String
        dispatch_async(dispatch_get_main_queue()) {
          self.imageTitle.text = photoTitle
        }

        guard let imageUrlString = choice[FlikrAPI.Keys.UrlExtra] as? String else {
          print("can't find \(FlikrAPI.Keys.UrlExtra) in \(choice)")
          return
        }

        print("imageUrlString: \(imageUrlString)")

        let imageUrl = NSURL(string: imageUrlString)

        if let imageData = NSData.init(contentsOfURL: imageUrl!) {
          print("got image data")
          let image = UIImage(data: imageData)
          print("image: \(image)")
          dispatch_async(dispatch_get_main_queue()) {
            self.imageView.image = image
          }
        }

      }
    })
    )

    print("tell dataTask to resume")
    dataTask.resume()
  }

  @IBAction func performGeoSearch(sender: UIButton) {
  }

  
}

