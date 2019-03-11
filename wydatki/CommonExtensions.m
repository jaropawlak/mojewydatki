//
//  CommonExtensions.m
//  wydatki
//
//  Created by Jarosław Pawlak on 22.10.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import "CommonExtensions.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "Expense.h"

@interface CommonExtensions()
@property NSManagedObjectContext* managedObjectContext;
@property CLLocationManager *locationManager;

@end
@implementation CommonExtensions
-(void)findClosestCategory
{
   
    _locationManager = [[CLLocationManager alloc] init];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager  requestWhenInUseAuthorization];
    }
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 0.2;
    //_locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" (%@ <= date AND date <= %@)",
                              [[NSDate date] dateByAddingTimeInterval:(60 * 60 * 24 * 14 * -1)], [NSDate date]];
    
    fetchRequest.predicate = predicate;
    [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"category",nil]];
    
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    
    //[fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray * locationData = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    CLLocation *currentLocation =_locationManager.location;
    CLLocationDistance maxDistance = 9999;
    Expense * closestExpense = nil;
    for (Expense *expense in locationData) {
        CLLocation *c = [[CLLocation alloc] initWithLatitude:expense.lat.doubleValue longitude:expense.lon.doubleValue];
        
        CLLocationDistance distance =  [currentLocation distanceFromLocation:c];
        if (distance < maxDistance && distance < 50) // nie dość, że bliżej, to jeszcze w promieniu 50m od tamtego
        {
            maxDistance = distance;
            closestExpense = expense;
        }
    }
    
    if (closestExpense != nil)
    {
  /*      int i = 0 ;
        while ([budgetCategories count] > i) {
            if ([[budgetCategories[i] name] isEqualToString:closestExpense.category.name])
            {
                [_categoryPicker selectRow:i inComponent:0 animated:NO];
                selectedTitle = closestExpense.category.name;
                selectedCategoryRowId = i;
                [self.categoryButton setTitle:selectedTitle forState:UIControlStateNormal];
                break;
            }
            ++i;
        }*/
        
    }
    
    
}
@end
