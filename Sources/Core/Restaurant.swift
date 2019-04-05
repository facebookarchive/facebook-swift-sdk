// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

// FOR SOURCERY DEMO ONLY. NOT THE REAL THING.

public struct Restaurant: Equatable {
  // Static constant Variable
  public static let soup: String = "Clam Chowder"

  // Static variable
  public static var bread: String = "Sourdough"

  // Variable
  public let name: String

  // Variable without a default value
  public var specials: [String]

  // Variable with a default value
  public var regularMenu: [String] = ["Sandwiches"]

  // Computed Variable
  public var orderTimestamp: Date {
    return Date()
  }

  public var employee: Employee

  // Enum Variable
  public var payrollEntry: EmployeePayroll

  public var payroll: [EmployeePayroll]

  // Private Variable
  // Note: Including a private var means we need to include a custom initializer
  // for the struct or the generated wrapper class will not compile.
  // This is not a huge deal but need to keep it in mind.
  private var registerCode: String

  // Public Variable
  public var bathroomCode: String

  public var uniformColors: UniformColors

  var timeNow: Date {
    return Date()
  }

  // Necessary because of a private var.
  // This would show up when we wanted to use it ourselves anyway so no big deal
  // but again worth noting that you are able to write a valid struct that will not generate into a valid wrapper class
  public init(
    name: String,
    specials: [String],
    regularMenu: [String],
    employee: Employee,
    payrollEntry: EmployeePayroll,
    payroll: [EmployeePayroll],
    bathroomCode: String,
    uniformColors: UniformColors
    ) {
    self.name = name
    self.specials = specials
    self.regularMenu = regularMenu
    self.bathroomCode = bathroomCode
    self.employee = employee
    self.payrollEntry = payrollEntry
    self.registerCode = "secret"
    self.uniformColors = uniformColors
    self.payroll = payroll
  }

  init(
    name: String,
    specials: [String],
    regularMenu: [String],
    employee: Employee,
    payrollEntry: EmployeePayroll,
    payroll: [EmployeePayroll],
    registerCode: String,
    bathroomCode: String,
    uniformColors: UniformColors
    ) {
    self.name = name
    self.specials = specials
    self.regularMenu = regularMenu
    self.registerCode = registerCode
    self.bathroomCode = bathroomCode
    self.employee = employee
    self.payrollEntry = payrollEntry
    self.uniformColors = uniformColors
    self.payroll = payroll
  }

  // Public Method that uses an internal property
  public func timeInOneHour() -> Date {
    return timeNow.addingTimeInterval(Double(60 * 60 * 60))
  }

  // Public method with a lot of parameters
  public func timeAdvanced(
    byHours hours: Int,
    minutes: Int,
    _ seconds: Int) {
    print("\(hours), \(minutes), \(seconds)")
  }

  public static func staticTimeAdvanced(
    byHours hours: Int,
    minutes: Int,
    _ seconds: Int) {
    print("\(hours), \(minutes), \(seconds)")
  }
  // Internal Method that uses an internal property

  // Public Method that takes an enum

  // Public Method that returns an enum

  // Public Method that returns a bridged type
}

// Phantom type to mark types that may be bridged to objc
protocol ObjCBridgeable {}

extension Restaurant: ObjCBridgeable {}
