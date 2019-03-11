//
//  BudgetViewController.m
//  wydatki
//
//  Created by jarek on 18.06.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import "BudgetViewController.h"
#import "BudgetCategory.h"
#import "BudgetTableViewCell.h"

@interface BudgetViewController ()
@property int rowCount;
@end

@implementation BudgetViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}
-(void)keyboardWillShow:(NSNotification *)notification
{
    CGRect frame =  self.tableView.frame;
    frame.size.height -= ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]).size.height;
    self.tableView.frame = frame;
}
-(void)keyboardWillHide:(NSNotification *)notification
{
    CGRect frame =  self.tableView.frame;
    frame.size.height += ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]).size.height;
    self.tableView.frame = frame;
}

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
    self.title = Localize(@"Budget");
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    _rowCount = [sectionInfo numberOfObjects];
    return _rowCount;
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
        NSString *CellIdentifier = @"BudgetCell";
        
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        BudgetCategory  *managedObject =
        (BudgetCategory*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        BudgetTableViewCell *tCell = (BudgetTableViewCell *)cell;
        if ([CellIdentifier isEqualToString:@"BudgetCell"])
        {
            if (![managedObject.name isEqualToString:@"?"])
            {
                tCell.nameTextField.text = managedObject.name;
            }
            else
            {
                tCell.nameTextField.text = nil;
            }
            if (managedObject.budget.doubleValue > 0.0)
            {
                tCell.limitTextField.text =[ NSString stringWithFormat:@"%@", managedObject.budget ];
            }
            else
            {
                tCell.limitTextField.text = nil;
            }
        }
        else
        {
            //TODO
       //     [tCell.updateButton setTitle:Localize(@"Update") forState:UIControlStateNormal];
            
        }
           // Configure the cell...
        
        return tCell;
    
   
}
-(void)prepareFetchedResultsController
{
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BudgetCategory" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:200];
    
    // Don't display unsaved cases
    [fetchRequest setIncludesPendingChanges:NO];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath: nil cacheName: nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        [self prepareFetchedResultsController];
    }
    return _fetchedResultsController;
}

- (IBAction)addBudgetItem:(UIBarButtonItem *)sender {
    //Category *category = (Category*)
    BudgetCategory* cat = [NSEntityDescription insertNewObjectForEntityForName:@"BudgetCategory" inManagedObjectContext:_managedObjectContext];
   // cat.name = @"?";
    cat.orderId =  [NSNumber numberWithInt:_rowCount++];
    
    [_managedObjectContext save:nil];
    
    [self.fetchedResultsController performFetch:nil];
    
    [self.tableView reloadData];
}

- (IBAction)editingFinished:(UITextField *)sender {
    BudgetTableViewCell* cell;
    
    UIView *someView = sender.superview.superview;//[self.tableView cellForRowAtIndexPath:selectedRow];
    if ([someView respondsToSelector:@selector(nameTextField)])
    {
        cell = (BudgetTableViewCell*)someView;
    }
    else
    {
        cell = (BudgetTableViewCell*)someView.superview;
    }

    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    BudgetCategory  *managedObject =
    (BudgetCategory*)[self.fetchedResultsController objectAtIndexPath:path];
    managedObject.name = cell.nameTextField.text;
    if (managedObject.name == nil || managedObject.name.length ==0)
    {
        managedObject.name = @"?";
    }
    managedObject.budget = [NSNumber numberWithInt:cell.limitTextField.text.intValue];
    [_managedObjectContext save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CATEGORIES" object:nil];
    //[self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BudgetCategory *t = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [_managedObjectContext deleteObject:t];
        [_managedObjectContext save:nil];
        
        //        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeDelete) {
        // Delete row from tableView.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    } else if (type == NSFetchedResultsChangeInsert)
    {
        [self.tableView reloadData];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return Localize(@"Category                         Expense limit");
}
@end
