//
//  ExpenseMapViewController.h
//  wydatki
//
//  Created by jarek on 30.06.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface ExpenseMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property double lat;
@property double lon;
@property NSString* expenseTitle;
@property NSString* expenseDescription;
@property NSString* expenseCategory;
@end
