//
//  Util.swift
//  FlikrFinder
//
//  Created by Michael Johnston on 16.10.2015.
//  Copyright © 2015 Metafeat Apps. All rights reserved.
//

import Foundation

extension Dictionary {
  mutating func unionByOverwriting<S: SequenceType where
    S.Generator.Element == (Key,Value)>(sequence: S) {
      for (key, value) in sequence {
        self[key] = value
      }
  }
}