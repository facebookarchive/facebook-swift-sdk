//
//  DialogFlow.swift
//  FacebookCore
//
//  Created by Joe Susnick on 6/7/19.
//  Copyright © 2019 Facebook Inc. All rights reserved.
//

import Foundation

struct DialogFlow {
  let name: String
  let shouldUseNativeFlow: Bool
  let shouldUseSafariVC: Bool

  init(remote: RemoteDialogFlow) {
    name = remote.name

    let shouldUseNativeFlow = remote.shouldUseNativeFlow == 1
    let shouldUseSafariVC = remote.shouldUseSafariVC == 1

    self.shouldUseNativeFlow = shouldUseNativeFlow
    self.shouldUseSafariVC = shouldUseSafariVC
  }
}
