// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT





import Foundation


@objc(FBRestaurant)
public class _ObjCRestaurant : NSObject {
  private (set) var restaurant: Restaurant

  // TODO: Probably remove this if no clear use case arises
  public init(restaurant: Restaurant) {
    self.restaurant = restaurant
  }

  // Initializer to be used from ObjC code
  @objc public init(
    name: String , 
    specials: [String] , 
    regularMenu: [String] , 
    employee: _ObjCEmployee, 
    payrollEntry: Any, 
    payroll: Any, 
    bathroomCode: String , 
    uniformColors: _ObjCUniformColors
  ) {
    guard let enumeration5 = payrollEntry as? _ObjCEmployeePayroll else {
      preconditionFailure("Type of enumeration not valid for payrollEntry")
    }
    guard let enumerations6 = payroll as? [_ObjCEmployeePayroll] else {
      preconditionFailure("Type of enumeration not valid for payroll")
    }
    let mappedEnumerations6 = enumerations6.map {
      $0.employeePayroll
    }
    let restaurant = Restaurant(
        name: name,
        specials: specials,
        regularMenu: regularMenu,
        employee: employee.employee,
        payrollEntry: enumeration5.employeePayroll,
        payroll: mappedEnumerations6,
        bathroomCode: bathroomCode,
        uniformColors: uniformColors.uniformColors
    )
    self.restaurant = restaurant
  }

  // Forwarding property for native type
  @objc public static var soup : String {
    return Restaurant.soup
  }

  // Forwarding property for native type
  @objc public static var bread : String {
    get {
      return Restaurant.bread
    }
    set {
      Restaurant.bread = newValue
    }
  }

  // Forwarding property for native type
  @objc public var name : String {
    return self.restaurant.name
  }

  // Forwarding property for native type
  @objc public var specials : [String] {
    get {
      return self.restaurant.specials
    }
    set {
      self.restaurant.specials = newValue
    }
  }

  // Forwarding property for native type
  @objc public var regularMenu : [String] {
    get {
      return self.restaurant.regularMenu
    }
    set {
      self.restaurant.regularMenu = newValue
    }
  }

  // Forwarding property for native type
  @objc public var orderTimestamp : Date {
    return self.restaurant.orderTimestamp
  }

  // Forwarding to custom type
  @objc public var employee : _ObjCEmployee {
    get {
      let value = self.restaurant.employee
      return _ObjCEmployee(employee: value)
    }

    set {
      self.restaurant.employee = newValue.employee
    }
  }

  // Computed property for enums
  @objc public var payrollEntry : Any {
    get {
      let value = self.restaurant.payrollEntry

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
        self.restaurant.payrollEntry = .hourly(for: caseValue.value1)
      }
      if let caseValue = newValue as? _ObjCEmployeePayrollSalary  {
        self.restaurant.payrollEntry = .salary(for: caseValue.value1)
      }
      if newValue as? _ObjCEmployeePayrollTerminated != nil  {
        self.restaurant.payrollEntry = .terminated
      }
    }
  }

  // Computed property for Array of enums
  @objc public var payroll : Any {
    get {
      let values = self.restaurant.payroll

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
      self.restaurant.payroll = backingValues
    }
  }


  // Forwarding property for native type
  @objc public var bathroomCode : String {
    get {
      return self.restaurant.bathroomCode
    }
    set {
      self.restaurant.bathroomCode = newValue
    }
  }

  // Forwarding to custom type
  @objc public var uniformColors : _ObjCUniformColors {
    get {
      let value = self.restaurant.uniformColors
      return _ObjCUniformColors(uniformColors: value)
    }

    set {
      self.restaurant.uniformColors = newValue.uniformColors
    }
  }

  // Forwarding property for native type
  @objc internal var timeNow : Date {
    return self.restaurant.timeNow
  }


    // Shortname timeInOneHour
    // Name timeInOneHour()
    // Forwarding method
    @objc public func timeInOneHour(
    ) { // Next: Deal with return type {
    self.restaurant.timeInOneHour(
    )
    }


    // Shortname timeAdvanced
    // Name timeAdvanced(    byHours hours: Int,    minutes: Int,    _ seconds: Int)
    // Forwarding method
    @objc public func timeAdvanced(
    byHours hours: Int,
    minutes minutes: Int,
    _ seconds: Int
    ) { // Next: Deal with return type {
    self.restaurant.timeAdvanced(
        byHours: hours,
        minutes: minutes,
        seconds
    )
    }


    // Shortname staticTimeAdvanced
    // Name staticTimeAdvanced(    byHours hours: Int,    minutes: Int,    _ seconds: Int)
    // Forwarding method
    @objc public static func staticTimeAdvanced(
    byHours hours: Int,
    minutes minutes: Int,
    _ seconds: Int
    ) { // Next: Deal with return type {
    Restaurant.staticTimeAdvanced(
        byHours: hours,
        minutes: minutes,
        seconds
    )
    }


}

@objc(FBUniformColors)
public class _ObjCUniformColors : NSObject {
  private (set) var uniformColors: UniformColors

  // TODO: Probably remove this if no clear use case arises
  public init(uniformColors: UniformColors) {
    self.uniformColors = uniformColors
  }


  // Forwarding property for native type
  @objc internal var hat : String {
    return self.uniformColors.hat
  }

  // Forwarding property for native type
  @objc internal var shirt : String {
    return self.uniformColors.shirt
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


    // Shortname < 
    // Name < (lhs: Employee, rhs: Employee)
    // Forwarding method
    @objc public static func < (
    _ 
  lhs: _ObjCEmployee, 
    _ 
  rhs: _ObjCEmployee
    ) { // Next: Deal with return type {
    Employee.< (
        lhs,
        rhs
    )
    }





}
