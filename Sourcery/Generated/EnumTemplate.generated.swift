// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation



// Bridging of enums

@objc(FBEmployeeClassification)
public class _ObjCEmployeeClassification : NSObject {
  private(set) var employeeClassification: EmployeeClassification

  // Initializer for Objective-C code
  @objc public init(caseValue: Any) {
    if let _ = caseValue as? _ObjCEmployeeClassificationManager {
      self.employeeClassification = .manager
    }
    else if let _ = caseValue as? _ObjCEmployeeClassificationContributor {
      self.employeeClassification = .contributor
    }
    else {
      preconditionFailure("Value \(caseValue) is not compatible with cases of EmployeeClassification")
    }
  }
}

// A case of EmployeeClassification
@objc(FBEmployeeClassificationManager)
public class _ObjCEmployeeClassificationManager : NSObject {

}

// A case of EmployeeClassification
@objc(FBEmployeeClassificationContributor)
public class _ObjCEmployeeClassificationContributor : NSObject {

}

@objc(FBEmployeePayroll)
public class _ObjCEmployeePayroll : NSObject {
  private(set) var employeePayroll: EmployeePayroll

  // Initializer for Objective-C code
  @objc public init(caseValue: Any) {
    if let caseValue = caseValue as? _ObjCEmployeePayrollHourly {
      self.employeePayroll = .hourly(
          for: caseValue.value1
      )
    }
    else if let caseValue = caseValue as? _ObjCEmployeePayrollSalary {
      self.employeePayroll = .salary(
          for: caseValue.value1
      )
    }
    else if let _ = caseValue as? _ObjCEmployeePayrollTerminated {
      self.employeePayroll = .terminated
    }
    else {
      preconditionFailure("Value \(caseValue) is not compatible with cases of EmployeePayroll")
    }
  }
}

// A case of EmployeePayroll
@objc(FBEmployeePayrollHourly)
public class _ObjCEmployeePayrollHourly : NSObject {
  let value1 : EmployeeClassification

  public init(value1 : EmployeeClassification ) {
    self.value1 = value1
  }
}

// A case of EmployeePayroll
@objc(FBEmployeePayrollSalary)
public class _ObjCEmployeePayrollSalary : NSObject {
  let value1 : EmployeeClassification

  public init(value1 : EmployeeClassification ) {
    self.value1 = value1
  }
}

// A case of EmployeePayroll
@objc(FBEmployeePayrollTerminated)
public class _ObjCEmployeePayrollTerminated : NSObject {

}

