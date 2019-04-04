// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT





import Foundation


@objc(FBRestaurant)
public class _ObjCRestaurant : NSObject {
  private (set) var restaurant: Restaurant

  // Initializer to be used from Swift code
  public init(restaurant: Restaurant) {
    self.restaurant = restaurant
  }

  // Initializer to be used from ObjC code
  @objc public init(
    name: String , 
    specials: [String] , 
    regularMenu: [String] = ["Sandwiches"], 
    employee: _ObjCEmployee, 

    payroll: Any, 
    registerCode: String , 
    bathroomCode: String 
  ) {
    // Unwrapping of enumeration
    guard let enumeration8 = payroll as? _ObjCEmployeePayroll else {
      preconditionFailure("Type of enumeration not valid for payroll")
    }

    let restaurant = Restaurant(
      name: name,
      specials: specials,
      regularMenu: regularMenu,
      employee: employee.employee,
      payroll: enumeration8.employeePayroll,
      registerCode: registerCode,
      bathroomCode: bathroomCode
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
  @objc public var payroll : Any {
    get {
      let value = self.restaurant.payroll

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
        self.restaurant.payroll = .hourly(for: caseValue.value1)
      }
      if let caseValue = newValue as? _ObjCEmployeePayrollSalary  {
        self.restaurant.payroll = .salary(for: caseValue.value1)
      }
      if newValue as? _ObjCEmployeePayrollTerminated != nil  {
        self.restaurant.payroll = .terminated
      }
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
}
