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
  @IBOutlet weak var searchInterfaceStackView: UIStackView!

//  var currentField:UITextField?

  var tapRecognizer: UITapGestureRecognizer? = nil
  var currentKeyboardHeight: CGFloat = 0
  var defaultViewFrame: CGRect!

  // MARK: Actions
  @IBAction func performPhraseSeach(sender: UIButton) {
    let urlSession = NSURLSession.sharedSession()
    let api = FlikrAPI()
    guard let searchText = nameSearchTextField.text where searchText.characters.count > 0 else {
      return
    }

    let request = api.photos_search_request(searchText)

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

  // MARK: Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
    tapRecognizer?.numberOfTapsRequired = 1
    print("Initialize the tapRecognizer in viewDidLoad")
    defaultViewFrame = view.frame
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    addKeyboardDismissRecognizer()
    subscribeToKeyboardNotifications()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeToKeyboardNotifications()
    removeKeyboardDismissRecognizer()
  }

  // MARK: Show/Hide Keyboard

  func addKeyboardDismissRecognizer() {
    print("add the recognizer to dismiss the keyboard")
    view.addGestureRecognizer(tapRecognizer!)
  }

  func removeKeyboardDismissRecognizer() {
    view.removeGestureRecognizer(tapRecognizer!)
  }

  func handleSingleTap(recognizer: UITapGestureRecognizer) {
    print("handleSingleTap. state: \(recognizer.state.rawValue)")
    if recognizer.state == .Ended {
      print("tell view to resign")
      view.endEditing(true)
    }
  }

  func subscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "keyboardWillShow:",
      name: UIKeyboardWillShowNotification,
      object: nil
    )
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "keyboardWillHide:",
      name: UIKeyboardWillHideNotification,
      object: nil
    )
  }

  func unsubscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }

  func keyboardWillShow(notification: NSNotification) {
    tapRecognizer!.enabled = true
    currentKeyboardHeight = getKeyboardHeight(notification)
    let spaceBelowSearchView = defaultViewFrame.height - searchInterfaceStackView.frame.origin.y - searchInterfaceStackView.frame.height
    let delta:CGFloat = (currentKeyboardHeight != 0)  ?
      currentKeyboardHeight - spaceBelowSearchView
      : 0.0
    view.frame.origin.y = defaultViewFrame.origin.y - delta
    print("Shift the view's frame up to make room for keyboard")
  }

  func keyboardWillHide(notification: NSNotification) {
    tapRecognizer!.enabled = false
    currentKeyboardHeight = 0
    view.frame.origin.y = defaultViewFrame.origin.y
    print("Shift the view's frame down so that the view is back to its original placement")
  }

  private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    return keyboardSize.CGRectValue().height
  }

}

