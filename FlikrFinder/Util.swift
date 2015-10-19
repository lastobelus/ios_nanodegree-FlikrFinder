//
//  Util.swift
//  FlikrFinder
//
//  Created by Michael Johnston on 16.10.2015.
//  Copyright © 2015 Metafeat Apps. All rights reserved.
//

import Foundation

// merge dictionaries in place
extension Dictionary {
  mutating func unionByOverwriting<S: SequenceType where
    S.Generator.Element == (Key,Value)>(sequence: S) {
      for (key, value) in sequence {
        self[key] = value
      }
  }
}

// clamp a value to bounds
func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
  return min(max(value, lower), upper)
}


// handle JSON values that are ints but can come across the wire as a string or number
protocol HasNumber {
  var integerValue: Int { get }
}
extension NSString:HasNumber{}
extension NSNumber:HasNumber{}
