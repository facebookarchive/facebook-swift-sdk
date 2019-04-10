// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT





import Foundation


@objc(FBCustomStruct)
public class _ObjCCustomStruct : NSObject {
  private (set) var customStruct: CustomStruct

  // TODO: Probably remove this if no clear use case arises
  public init(customStruct: CustomStruct) {
    self.customStruct = customStruct
  }

  // Initializer to be used from ObjC code
  @objc public init(
    // Native type
    stringConstant: String,
    // Native type
    stringArray: [String],
    // Native type
    stringArrayWithDefaultValue: [String],
    // Class or struct
    customClassVariable: _ObjCEmployee,
    // Enum
    enumVariable: Any,
    // Enum Array
    enumArrayVariable: Any,
    // Native type
    stringVariable: String,
    // Class or struct
    structVariable: _ObjCStructWithGeneratedInitializer
  ) {
    guard let enumeration5 = enumVariable as? _ObjCEmployeePayroll else {
      preconditionFailure("Type of enumeration not valid for enumVariable")
    }
    guard let enumerations6 = enumArrayVariable as? [_ObjCEmployeePayroll] else {
      preconditionFailure("Type of enumeration not valid for enumArrayVariable")
    }
    let mappedEnumerations6 = enumerations6.map {
      $0.employeePayroll
    }
    let customStruct = CustomStruct(
        stringConstant: stringConstant,
        stringArray: stringArray,
        stringArrayWithDefaultValue: stringArrayWithDefaultValue,
        customClassVariable: customClassVariable.employee,
        enumVariable: enumeration5.employeePayroll,
        enumArrayVariable: mappedEnumerations6,
        stringVariable: stringVariable,
        structVariable: structVariable.structWithGeneratedInitializer
    )
    self.customStruct = customStruct
  }

  // Forwarding property for native type
  @objc public static var staticStringConstant : String {
    return CustomStruct.staticStringConstant
  }

  // Forwarding property for native type
  @objc public static var staticStringVariable : String {
    get {
      return CustomStruct.staticStringVariable
    }
    set {
      CustomStruct.staticStringVariable = newValue
    }
  }

  // Forwarding property for native type
  @objc public var stringConstant : String {
    return self.customStruct.stringConstant
  }

  // Forwarding property for native type
  @objc public var stringArray : [String] {
    get {
      return self.customStruct.stringArray
    }
    set {
      self.customStruct.stringArray = newValue
    }
  }

  // Forwarding property for native type
  @objc public var stringArrayWithDefaultValue : [String] {
    get {
      return self.customStruct.stringArrayWithDefaultValue
    }
    set {
      self.customStruct.stringArrayWithDefaultValue = newValue
    }
  }

  // Forwarding property for native type
  @objc public var computedDate : Date {
    return self.customStruct.computedDate
  }

  // Forwarding to custom type
  @objc public var customClassVariable : _ObjCEmployee {
    get {
      let value = self.customStruct.customClassVariable
      return _ObjCEmployee(employee: value)
    }

    set {
      self.customStruct.customClassVariable = newValue.employee
    }
  }

  // Computed property for enums
  @objc public var enumVariable : Any {
    get {
      let value = self.customStruct.enumVariable

      switch value {
      case .hourly(let value1):
        return _ObjCEmployeePayrollHourly(
          value1: value1
        )

      case .salary(let value1):
        return _ObjCEmployeePayrollSalary(
          value1: value1
        )

      case .terminated:
        return _ObjCEmployeePayrollTerminated()
      }
    }
    set {
      if let caseValue = newValue as? _ObjCEmployeePayrollHourly  {
        self.customStruct.enumVariable = .hourly(for: caseValue.value1)
      }
      if let caseValue = newValue as? _ObjCEmployeePayrollSalary  {
        self.customStruct.enumVariable = .salary(for: caseValue.value1)
      }
      if newValue as? _ObjCEmployeePayrollTerminated != nil  {
        self.customStruct.enumVariable = .terminated
      }
    }
  }

  // Computed property for Array of enums
  @objc public var enumArrayVariable : Any {
    get {
      let values = self.customStruct.enumArrayVariable

      return values.map { value -> Any in
        switch value {
        case .hourly(let value1):
          return _ObjCEmployeePayrollHourly(
            value1: value1
          )

        case .salary(let value1):
          return _ObjCEmployeePayrollSalary(
            value1: value1
          )

        case .terminated:
          return _ObjCEmployeePayrollTerminated()
        }
      } as Any
    }
    set {
      var backingValues = [EmployeePayroll]()

      guard let newValues = newValue as? [AnyObject] else {
        return assertionFailure("Must be able to cast any into array of objects")
      }

      newValues.forEach { value in

        if let caseValue = value as? _ObjCEmployeePayrollHourly  {
          backingValues.append(.hourly(for: caseValue.value1))
        }

        if let caseValue = value as? _ObjCEmployeePayrollSalary  {
          backingValues.append(.salary(for: caseValue.value1))
        }

        if value as? _ObjCEmployeePayrollTerminated != nil  {
          backingValues.append(.terminated)
        }
      }
      self.customStruct.enumArrayVariable = backingValues
    }
  }


  // Forwarding property for native type
  @objc public var stringVariable : String {
    get {
      return self.customStruct.stringVariable
    }
    set {
      self.customStruct.stringVariable = newValue
    }
  }

  // Forwarding to custom type
  @objc public var structVariable : _ObjCStructWithGeneratedInitializer {
    get {
      let value = self.customStruct.structVariable
      return _ObjCStructWithGeneratedInitializer(structWithGeneratedInitializer: value)
    }

    set {
      self.customStruct.structVariable = newValue.structWithGeneratedInitializer
    }
  }

  // Forwarding property for native type
  @objc internal var computedInternalDateVariable : Date {
    return self.customStruct.computedInternalDateVariable
  }

  @objc public func methodWithNoParametersReturnsNativeType(
    ) -> Date {
    return self.customStruct.methodWithNoParametersReturnsNativeType(
    )
  }
  @objc public func methodWithParameters(
      byHours hours: Int,
      minutes: Int,
      _ seconds: Int
    ) -> Void {
    return self.customStruct.methodWithParameters(
      byHours: hours,
      minutes: minutes,
      seconds
    )
  }
  @objc public static func staticMethodWithParameters(
      byHours hours: Int,
      minutes: Int,
      _ seconds: Int
    ) -> Void {
    return CustomStruct.staticMethodWithParameters(
      byHours: hours,
      minutes: minutes,
      seconds
    )
  }
  @objc public func methodWithNoParametersReturnsClass(
    ) -> _ObjCEmployee {
    let backingType = self.customStruct.methodWithNoParametersReturnsClass(
    )
    return _ObjCEmployee(
        employee: backingType
    )
  }
  @objc public func mutatingMethod(
    // Custom Type parameter
  // Class or struct
  newColors: _ObjCStructWithGeneratedInitializer
    ) -> Void {
    return self.customStruct.mutatingMethod(
      newColors: newColors.structWithGeneratedInitializer
    )
  }
  @objc public override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? _ObjCCustomStruct else {
      return false
    }
    return customStruct == object.customStruct
  }

}

@objc(FBStructWithGeneratedInitializer)
public class _ObjCStructWithGeneratedInitializer : NSObject {
  private (set) var structWithGeneratedInitializer: StructWithGeneratedInitializer

  // TODO: Probably remove this if no clear use case arises
  public init(structWithGeneratedInitializer: StructWithGeneratedInitializer) {
    self.structWithGeneratedInitializer = structWithGeneratedInitializer
  }

  @objc override public init() {
    self.structWithGeneratedInitializer = StructWithGeneratedInitializer()
  }

  // Forwarding property for native type
  @objc internal var hat : String {
    return self.structWithGeneratedInitializer.hat
  }

  // Forwarding property for native type
  @objc internal var shirt : String {
    return self.structWithGeneratedInitializer.shirt
  }

  @objc public override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? _ObjCStructWithGeneratedInitializer else {
      return false
    }
    return structWithGeneratedInitializer == object.structWithGeneratedInitializer
  }

}

@objc(FBEmployee)
public class _ObjCEmployee : NSObject {
  private (set) var employee: Employee

  // TODO: Probably remove this if no clear use case arises
  public init(employee: Employee) {
    self.employee = employee
  }

  // Initializer to be used from ObjC code
  @objc public init(
    // Enum
    classification: Any
  ) {
    guard let enumeration1 = classification as? _ObjCEmployeeClassification else {
      preconditionFailure("Type of enumeration not valid for classification")
    }
    let employee = Employee(
        classification: enumeration1.employeeClassification
    )
    self.employee = employee
  }

  // Computed property for enums
  @objc public var classification : Any {
      let value = self.employee.classification

      switch value {
      case .manager:
        return _ObjCEmployeeClassificationManager()

      case .contributor:
        return _ObjCEmployeeClassificationContributor()
      }
  }

  @objc public override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? _ObjCEmployee else {
      return false
    }
    return employee == object.employee
  }

  // Comparable passthrough
  @objc public func compare(_ object: _ObjCEmployee) -> ComparisonResult {
    if employee == object.employee {
      return .orderedSame
    } else if employee < object.employee {
      return .orderedAscending
    } else {
      return .orderedDescending
    }
  }
}
