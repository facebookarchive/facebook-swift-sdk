// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT




import Foundation

// Bridging of enums

@objc(FBEmployeeClassification)
public class _ObjCEmployeeClassification : NSObject {

    // Enum has cases
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


  // Comparable passthrough
  @objc public func compare(_ object: _ObjCEmployeeClassification) -> ComparisonResult {
    if employeeClassification == object.employeeClassification {
      return .orderedSame
    } else if employeeClassification < object.employeeClassification {
      return .orderedAscending
    } else {
      return .orderedDescending
    }
  }
}

// A case of EmployeeClassification
@objc(FBEmployeeClassificationManager)
public class _ObjCEmployeeClassificationManager : NSObject {


  // Create initializer for the associated value
  @objc public override init() {}
}

// A case of EmployeeClassification
@objc(FBEmployeeClassificationContributor)
public class _ObjCEmployeeClassificationContributor : NSObject {


  // Create initializer for the associated value
  @objc public override init() {}
}

@objc(FBEmployeePayroll)
public class _ObjCEmployeePayroll : NSObject {

    // Enum has cases
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


  // Computed property for enums
  @objc internal var classification : Any? {
      guard let value = self.employeePayroll.classification else {
        return nil;
      }

      switch value {
      case .manager:
        return _ObjCEmployeeClassificationManager()

      case .contributor:
        return _ObjCEmployeeClassificationContributor()
      }
  }

  @objc public func getClassification(
    ) -> _ObjCEmployeeClassification? {
    let backingType = self.employeePayroll.getClassification(
    )
    return _ObjCEmployeeClassification(
        caseValue: backingType as Any
    )
  }
}

// A case of EmployeePayroll
@objc(FBEmployeePayrollHourly)
public class _ObjCEmployeePayrollHourly : NSObject {
  let value1 : EmployeeClassification

  init(value1 : EmployeeClassification ) {
    self.value1 = value1
  }

  // Create initializer for the associated value
  @objc public init(value1 : _ObjCEmployeeClassification ) {
    self.value1 = value1.employeeClassification
  }
}

// A case of EmployeePayroll
@objc(FBEmployeePayrollSalary)
public class _ObjCEmployeePayrollSalary : NSObject {
  let value1 : EmployeeClassification

  init(value1 : EmployeeClassification ) {
    self.value1 = value1
  }

  // Create initializer for the associated value
  @objc public init(value1 : _ObjCEmployeeClassification ) {
    self.value1 = value1.employeeClassification
  }
}

// A case of EmployeePayroll
@objc(FBEmployeePayrollTerminated)
public class _ObjCEmployeePayrollTerminated : NSObject {


  // Create initializer for the associated value
  @objc public override init() {}
}

