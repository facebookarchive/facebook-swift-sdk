//
//  SampleInfoDictionary.swift
//  FacebookCoreTests
//
//  Created by Joe Susnick on 5/20/19.
//  Copyright © 2019 Facebook Inc. All rights reserved.
//

@testable import FacebookCore
import Foundation

enum SampleInfoDictionary {
  static func validURLSchemes(schemes: [String]) -> [String: Any] {
    return [
      Settings.PListKeys.cfBundleURLTypes:
        [
          [
            Settings.PListKeys.cfBundleURLSchemes: schemes
          ]
      ]
    ]
  }
}
