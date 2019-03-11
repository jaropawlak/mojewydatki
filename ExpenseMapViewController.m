//
//  ExpenseMapViewController.m
//  wydatki
//
//  Created by jarek on 30.06.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import "ExpenseMapViewController.h"

@interface ExpenseMapViewController ()

@end

@implementation ExpenseMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MKCoordinateRegion region;
    region.center.longitude = _lon;
    region.center.latitude = _lat;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    region.span = span;
   // [self.mapView setCenterCoordinate:region.center];
    [self.mapView setRegion:region];
    CLLocationCoordinate2D annotationCoord;
    
    annotationCoord.latitude = _lat;
    annotationCoord.longitude = _lon;
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    annotationPoint.title = self.expenseTitle;
    
    if (_expenseCategory == nil)
    {
        _expenseCategory = @"";
    }
    if (_expenseDescription == nil)
    {
        _expenseDescription = @"";
    }
    annotationPoint.subtitle =[ NSString stringWithFormat:@"%@ %@",self.expenseCategory, self.expenseDescription];
    [_mapView addAnnotation:annotationPoint];
   
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
