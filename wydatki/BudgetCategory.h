//
//  BudgetCategory.h
//  wydatki
//
//  Created by Jarosław Pawlak on 22.10.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Expense;

@interface BudgetCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * budget;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSSet *expenses;
@end

@interface BudgetCategory (CoreDataGeneratedAccessors)

- (void)addExpensesObject:(Expense *)value;
- (void)removeExpensesObject:(Expense *)value;
- (void)addExpenses:(NSSet *)values;
- (void)removeExpenses:(NSSet *)values;

@end
