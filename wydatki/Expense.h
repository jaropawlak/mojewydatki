//
//  Expense.h
//  wydatki
//
//  Created by Jarosław Pawlak on 22.10.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BudgetCategory;

@interface Expense : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * expenseType;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) BudgetCategory *category;

@end
