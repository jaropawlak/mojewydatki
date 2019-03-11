//
//  BudgetViewController.h
//  wydatki
//
//  Created by jarek on 18.06.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


#import "AdViewController.h"
@interface BudgetViewController : AdViewController<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
- (IBAction)addBudgetItem:(UIBarButtonItem *)sender;
- (IBAction)editingFinished:(UITextField *)sender;

@end
