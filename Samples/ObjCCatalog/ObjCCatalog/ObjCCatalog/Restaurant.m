//
//  Restaurant.m
//  IntegratingSDK
//
//  Created by Joe Susnick on 4/3/19.
//  Copyright © 2019 facebook. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant

-(FBCustomStruct *)openRestaurant {
    FBEmployeeClassificationManager *manager = [FBEmployeeClassificationManager new];

    FBEmployeeClassification *employeeClassification = [[FBEmployeeClassification alloc] initWithCaseValue:manager];
    FBEmployeePayrollHourly *hourly = [[FBEmployeePayrollHourly alloc] initWithValue1:employeeClassification];
    FBEmployeePayroll *payrollEntry = [[FBEmployeePayroll alloc] initWithCaseValue:hourly];
    FBEmployee *employee = [[FBEmployee alloc] initWithClassification:manager];
    NSArray<FBEmployeePayroll *> *payroll = @[payrollEntry, payrollEntry, payrollEntry];
    FBStructWithGeneratedInitializer *uniformColors = [[FBStructWithGeneratedInitializer alloc] init];

    FBCustomStruct *restaurant = [[FBCustomStruct alloc] initWithStringConstant:@"Mama Cass's Sandwich Shack"
                                                                    stringArray:@[@"Ham sammiches"]
                                                    stringArrayWithDefaultValue:@[@"PB&Js"]
                                                            customClassVariable:employee
                                                                   enumVariable:employeeClassification
                                                              enumArrayVariable:payroll
                                                                 stringVariable:@"123"
                                                                 structVariable:uniformColors];

    return restaurant;
}

-(NSString *)staticValueOnCustomStruct {
    return [FBCustomStruct staticStringConstant];
}


@end
