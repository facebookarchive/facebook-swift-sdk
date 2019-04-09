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


@objc(FBGraph)
public class _ObjCGraph : NSObject {

  @objc public override init() {}


  @objc public static func fetchObject(
      identifiedBy identifier: String,
      completionHandler:
        (
          Data?,
          Error?
        ) -> Void
    ) -> Void {
    return Graph.fetchObject(
      identifiedBy: identifier,
      // check if it's last?
      completionHandler: { result in
        // This is making the large assumption that a closure will be a Swift.Result type that takes two generic types
        switch result {
        case .success(let value):
          completionHandler(value, nil)
        case .failure(let error):
          completionHandler(nil, error)
        }
      }
    )
  }
}


@objc(FBParser)
public class _ObjCParser : NSObject {

  @objc public override init() {}


  @objc public static func getSomeData(
    ) -> Data {
    return Parser.getSomeData(
    )
  }
}

