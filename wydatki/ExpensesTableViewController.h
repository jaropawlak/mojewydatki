//
//  ExpensesTableViewController.h
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AdViewController.h"

@interface ExpensesTableViewController : AdViewController<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
@property NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (IBAction)updateButtonClicked:(UIButton *)sender;
@property NSDate *dateFrom;
@property NSDate *dateTo;

@property BOOL cash;
@property BOOL card;
@property BOOL transfer;
@property BOOL cashoutATM;
@property NSString* selectedTitle;
- (IBAction)previewPictureClicked:(UIButton*)sender;
- (IBAction)categoryClicked:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
