//
//  Restaurant.m
//  IntegratingSDK
//
//  Created by Joe Susnick on 4/3/19.
//  Copyright © 2019 facebook. All rights reserved.
//

#import "Restaurant.h"
@import FacebookCore;

@implementation Restaurant

-(FBRestaurant *)openRestaurant {
    FBEmployeeClassification *payrollEntry = [[FBEmployeeClassification alloc] initWithCaseValue:[FBEmployeeClassificationManager new]];

    FBRestaurant *restaurant = [[FBRestaurant alloc] initWithName: @"Mama Cass's Sandwich Shack"
                                                         specials: @[@"Ham sammiches"]
                                                      regularMenu: @[@"PB&Js"]
                                                         employee: [[FBEmployee alloc] initWithClassification: payrollEntry]
                                                          payroll: payrollEntry
                                                     registerCode: @"123"
                                                     bathroomCode: @"345"];
    return restaurant;
}

-(NSString *)soupOfTheDay {
    return [FBRestaurant soup];
}


@end
