//
//  AccessTokenWalletTests.swift
//  FacebookCoreTests
//
//  Created by Joe Susnick on 3/1/19.
//  Copyright © 2019 Facebook Inc. All rights reserved.
//

@testable import FacebookCore
import XCTest

class AccessTokenWalletTests: XCTestCase {

  func testEmptyWallet() {
    XCTAssertNil(AccessTokenWallet.currentAccessToken,
                 "The access token wallet should not have an access token by default")
  }

}
