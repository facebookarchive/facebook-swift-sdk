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

public struct CustomStruct: Equatable {
  // Static constant Variable
  public static let staticStringConstant: String = "Clam Chowder"

  // Static variable
  public static var staticStringVariable: String = "Sourdough"

  // Variable
  public let stringConstant: String

  // Variable without a default value
  public var stringArray: [String]

  // Variable with a default value
  public var stringArrayWithDefaultValue: [String] = ["Sandwiches"]

  // Computed Variable
  public var computedDate: Date {
    return Date()
  }

  // Variable that is a class
  public var customClassVariable: Employee

  // Variable that is an enum
  public var enumVariable: EmployeePayroll

  // Variable that is an array of enum
  public var enumArrayVariable: [EmployeePayroll]

  private var privateStringVariable: String

  // Public Variable
  public var stringVariable: String

  public var structVariable: StructWithGeneratedInitializer

  // Computed internal var
  var computedInternalDateVariable: Date {
    return Date()
  }

  public init(
    stringConstant: String,
    stringArray: [String],
    stringArrayWithDefaultValue: [String],
    customClassVariable: Employee,
    enumVariable: EmployeePayroll,
    enumArrayVariable: [EmployeePayroll],
    stringVariable: String,
    structVariable: StructWithGeneratedInitializer
    ) {
    self.stringConstant = stringConstant
    self.stringArray = stringArray
    self.stringArrayWithDefaultValue = stringArrayWithDefaultValue
    self.stringVariable = stringVariable
    self.customClassVariable = customClassVariable
    self.enumVariable = enumVariable
    self.privateStringVariable = "secret"
    self.structVariable = structVariable
    self.enumArrayVariable = enumArrayVariable
  }

  init(
    stringConstant: String,
    stringArray: [String],
    stringArrayWithDefaultValue: [String],
    customClassVariable: Employee,
    enumVariable: EmployeePayroll,
    enumArrayVariable: [EmployeePayroll],
    privateStringVariable: String,
    stringVariable: String,
    structVariable: StructWithGeneratedInitializer
    ) {
    self.stringConstant = stringConstant
    self.stringArray = stringArray
    self.stringArrayWithDefaultValue = stringArrayWithDefaultValue
    self.privateStringVariable = privateStringVariable
    self.stringVariable = stringVariable
    self.customClassVariable = customClassVariable
    self.enumVariable = enumVariable
    self.structVariable = structVariable
    self.enumArrayVariable = enumArrayVariable
  }

  public func methodWithNoParametersReturnsNativeType() -> Date {
    return computedInternalDateVariable.addingTimeInterval(Double(60 * 60 * 60))
  }

  public func methodWithParameters(
    byHours hours: Int,
    minutes: Int,
    _ seconds: Int) {
    print("\(hours), \(minutes), \(seconds)")
  }

  public static func staticMethodWithParameters(
    byHours hours: Int,
    minutes: Int,
    _ seconds: Int) {
    print("\(hours), \(minutes), \(seconds)")
  }

  public func methodWithNoParametersReturnsClass() -> Employee {
    return customClassVariable
  }

  public mutating func mutatingMethod(newColors: StructWithGeneratedInitializer) {
    self.structVariable = newColors
  }
  // Public Method that takes an enum

  // Public Method that returns an enum

  // Public Method that returns a bridged type
}

// Phantom type to mark types that may be bridged to objc
protocol ObjCBridgeable {}

extension CustomStruct: ObjCBridgeable {}
