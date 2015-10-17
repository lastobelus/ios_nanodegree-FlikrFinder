//
//  FlikrAPI.swift
//  FlikrFinder
//
//  Created by Michael Johnston on 16.10.2015.
//  Copyright © 2015 Metafeat Apps. All rights reserved.
//

import Foundation

struct FlikrAPI {
  static let Base = "https://api.flickr.com/services/rest/"
  static let APIKey = "bcfc3a5c2a4d459719ce8efa1e2cf5d2"
  static let baseQueryItems = [
    NSURLQueryItem(name: "api_key", value: APIKey),
    NSURLQueryItem(name: "format", value: "json"),
    NSURLQueryItem(name: "nojsoncallback", value: "1")
  ]

  struct Methods {
    static let PhotosSearch = "flickr.photos.search"
  }

  struct Keys {
    static let Method = "method"
    static let SafeSearch = "safe_search"
    static let Text = "text"
    static let PhotosSearchResult = "photos"
    static let Extras = "extras"
    static let UrlExtra = "url_m"
  }

  let API_KEY = "ENTER_YOUR_API_KEY_HERE"
  let EXTRAS = "url_m"
  let SAFE_SEARCH = "1"
  let DATA_FORMAT = "json"
  let NO_JSON_CALLBACK = "1"
  

  func method_url(method method: String, withOptions options: [String:String]) -> NSURL {
    let url = NSURLComponents(string: FlikrAPI.Base)!

    var queryItems = FlikrAPI.baseQueryItems
    queryItems.append(NSURLQueryItem(name: FlikrAPI.Keys.Method, value: method))
    for (key, value) in options {
      queryItems.append(NSURLQueryItem(name: key, value: value))
    }
    url.queryItems = queryItems


    return url.URL!
  }

//  let photoSearchURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=bcfc3a5c2a4d459719ce8efa1e2cf5d2&text=baby+asian+elephant&format=json&nojsoncallback=1"


  func photos_search_request(search_text: String) -> NSURLRequest {
    let options = [
      FlikrAPI.Keys.Text: search_text,
      FlikrAPI.Keys.SafeSearch: "1",
      FlikrAPI.Keys.Extras: FlikrAPI.Keys.UrlExtra
    ]

    let url = method_url(
      method: FlikrAPI.Methods.PhotosSearch,
      withOptions: options
    )

    return NSURLRequest(URL: url)
  }

  func handleResult(uri:String, completion: ([String:AnyObject]) -> Void)(data:NSData?, response:NSURLResponse?, error:NSError?) {
    guard error == nil else {
      print("error fetching url \(uri): \(error)")
      return
    }

    /* GUARD: Did we get a successful 2XX response? */
    guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
      if let response = response as? NSHTTPURLResponse {
        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
      } else if let response = response {
        print("Your request returned an invalid response! Response: \(response)!")
      } else {
        print("Your request returned an invalid response!")
      }
      return
    }

    /* GUARD: Was there any data returned? */
    guard let data = data else {
      print("No data was returned from url \(uri)!")
      return
    }

    let parsedResult: [String:AnyObject]!

    do {
      parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String:AnyObject]
    } catch let error as NSError {
      parsedResult = nil
      print("error parsing data returned from url \(uri): \(error.localizedDescription)")
    }

    /* GUARD: Did Flickr return an error? */
    guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
      print("Flickr API returned an error for \(uri). See error code and message in \(parsedResult)")
      return
    }

    completion(parsedResult )
  }

}
