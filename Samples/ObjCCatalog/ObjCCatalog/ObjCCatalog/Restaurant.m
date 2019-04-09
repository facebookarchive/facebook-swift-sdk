//
//  Restaurant.m
//  IntegratingSDK
//
//  Created by Joe Susnick on 4/3/19.
//  Copyright © 2019 facebook. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

-(FBRestaurant *)openRestaurant {
    FBEmployeeClassification *employeeClassification = [[FBEmployeeClassification alloc] initWithCaseValue:[FBEmployeeClassificationManager new]];
    FBEmployeePayroll *employeePayrollEntry = [[FBEmployeePayroll alloc] initWithCaseValue: [[FBEmployeePayrollHourly alloc] initWithValue: ]];
    FBEmployee *employee = [[FBEmployee alloc] initWithClassification:employeeClassification];

    FBRestaurant *restaurant = [[FBRestaurant alloc] initWithName:@"Mama Cass's Sandwich Shack"
                                                         specials:@[@"Ham sammiches"]
                                                      regularMenu:@[@"PB&Js"]
                                                         employee:employee
                                                     payrollEntry:<#(id _Nonnull)#>
                                                          payroll:<#(id _Nonnull)#>
                                                     bathroomCode:<#(NSString * _Nonnull)#>
                                                    uniformColors:<#(FBUniformColors * _Nonnull)#>]
    FBRestaurant *restaurant = [[FBRestaurant alloc] initWithName:@"Mama Cass's Sandwich Shack"
                                                         specials:
                                                      regularMenu:
                                                          payroll:payrollEntry
                                                     registerCode:@"123"
                                                     bathroomCode:@"456"];
    return restaurant;
}

-(NSString *)soupOfTheDay {
    return [FBRestaurant soup];
}


@end
