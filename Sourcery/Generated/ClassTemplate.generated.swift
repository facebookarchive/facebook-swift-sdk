// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation


@objc(FBEmployee)
public class _ObjCEmployee : NSObject {
  private (set) var employee: Employee

  // Initializer to be used from Swift code
  public init(employee: Employee) {
    self.employee = employee
  }

  // Initializer to be used from ObjC code
  @objc public init(
    classification: Any
  ) {
    // Unwrapping of enumeration
    guard let enumeration1 = classification as? _ObjCEmployeeClassification else {
      preconditionFailure("Type of enumeration not valid for classification")
    }
    let employee = Employee(
      classification: enumeration1.employeeClassification
    )
    self.employee = employee
  }

  // Computed property for enums
  public var classification : Any {
      let value = self.employee.classification

      switch value {
         case .manager:
            return _ObjCEmployeeClassificationManager()
         case .contributor:
            return _ObjCEmployeeClassificationContributor()
      }
  }

}
