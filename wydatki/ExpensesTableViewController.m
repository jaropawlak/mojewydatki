//
//  ExpensesTableViewController.m
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import "ExpensesTableViewController.h"
#import "Expense.h"
#import "ExpenseTableCell.h"
#import "BudgetCategory.h"
#import "ImagePreviewViewController.h"
#import "ExpenseMapViewController.h"
#import "NSString+FontAwesome.h"

@interface ExpensesTableViewController ()

@end

@implementation ExpensesTableViewController
NSString *selectedTitle;
int selectedCategoryRow=0;


NSDateFormatter* dateFormatter;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    images = [NSMutableDictionary new];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSLocale* locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
    self.tableView.delegate = self;
}
NSMutableDictionary* images;

-(void)viewWillAppear:(BOOL)animated
{
    selectedRow = nil;
    [super viewWillAppear:animated];
    if (imageIndexPath != nil)
    {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:imageIndexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
        imageIndexPath = nil;
    }
    [self prepareSums];
    [self loadCategories];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0)
    {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    }
    else return [sums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0)
    {
          NSString *CellIdentifier = @"ExpenseCell";
       
        if (selectedRow != nil && selectedRow.section ==0 && selectedRow.row == indexPath.row)
        {
              CellIdentifier = @"SelectedCell";
        }
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    Expense  *managedObject =
    (Expense*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ExpenseTableCell *tCell = (ExpenseTableCell *)cell;
    if ([CellIdentifier isEqualToString:@"ExpenseCell"])
    {
        tCell.date.text = [dateFormatter stringFromDate:managedObject.date];
        tCell.amount.text = [managedObject.amount descriptionWithLocale:[NSLocale currentLocale]];
        tCell.paymentType.text = [self getPaymentDescriptionFor:managedObject.expenseType.intValue];
        tCell.title.text = managedObject.title;
        tCell.category.text = managedObject.category.name;
        tCell.lon = managedObject.lon.doubleValue;
        tCell.lat = managedObject.lat.doubleValue;
    }
    else
    {
        tCell.dateTextField.text =[dateFormatter stringFromDate:managedObject.date];
        currentDateField =tCell.dateTextField;
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
        _datePicker.date = managedObject.date;
        tCell.dateTextField.inputView = _datePicker;
        NSString* categoryName = managedObject.category.name;
        if (categoryName == nil || [categoryName length] == 0)
        {
            categoryName = Localize(@"No Category");
        }
        [tCell.categoryButton setTitle:categoryName forState:UIControlStateNormal];
        int i = 0 ;
        while ([myBudgetCategories count] > i) {
            if ([[myBudgetCategories[i] name] isEqualToString:managedObject.category.name])
            {
                [tCell.categoryPicker selectRow:i inComponent:0 animated:NO];
                selectedTitle = managedObject.category.name;
                selectedCategoryRow = i;
                break;
            }
            ++i;
        }

        tCell.amountTextField.text = [managedObject.amount descriptionWithLocale:[NSLocale currentLocale]];
        tCell.paymentTypeSegment.selectedSegmentIndex = managedObject.expenseType.intValue;
        tCell.descriptionTextField.text = managedObject.title;
        [tCell.updateButton setTitle:Localize(@"Update") forState:UIControlStateNormal];

    }
        if (managedObject.photoPath)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:
                              managedObject.photoPath];
            UIImage* image = [images objectForKey:path];
            if (image == nil)
            {
                image = [UIImage imageWithContentsOfFile:path];
                [images setValue:image forKey:path];
            }
            [tCell.imagePreviewButton setBackgroundImage:image forState:UIControlStateNormal];
            [tCell.imagePreviewButton setHidden:NO];
            
        }
        else
        {
             [tCell.imagePreviewButton setHidden:YES];
        }
        
        tCell.amountLabel.text = [NSString fontAwesomeIconStringForEnum:FAMoney];
        tCell.descriptionLabel.text = [NSString fontAwesomeIconStringForEnum:FAFileTextO];
        tCell.dateLabel.text = [NSString fontAwesomeIconStringForEnum:FAClockO];
        tCell.typeLabel.text = [NSString fontAwesomeIconStringForEnum:FAbank];
        tCell.categoryLabel.text = [NSString fontAwesomeIconStringForEnum:FATag];
        [tCell.goToLocation setTitle:[NSString fontAwesomeIconStringForEnum:FApaperPlaneO] forState:UIControlStateNormal];
        [tCell.paymentTypeSegment setTitle:Localize(@"Cash") forSegmentAtIndex:0];
        [tCell.paymentTypeSegment setTitle:Localize(@"Card") forSegmentAtIndex:1];
        [tCell.paymentTypeSegment setTitle:Localize(@"Transfer") forSegmentAtIndex:2];
        [tCell.paymentTypeSegment setTitle:Localize(@"AtmMachine") forSegmentAtIndex:3];

    // Configure the cell...
    
    return tCell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SumCell"];
        NSString* key = [[sums allKeys] objectAtIndex:indexPath.row];
        
        NSNumber *sum = [sums valueForKey:key];
        cell.textLabel.text = [self getPaymentDescriptionFor:key.intValue];
        cell.detailTextLabel.text = sum.description;
        return cell;
    }
}
-(void)prepareSums
{
    sums = [NSMutableDictionary dictionaryWithCapacity:4];
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSArray* data = [sectionInfo objects];
    for (int i = 0 ; i < data.count ; ++i)
    {
        Expense* e = [data objectAtIndex:i];
        [self updateSums:e];
    }
    
    
}
-(NSString*)getPaymentDescriptionFor:(int)paymentCode
{
    switch (paymentCode) {
        case 0:
            return Localize(@"Cash");
            
        case 1:
            return Localize(@"Card");
           
        case 2:
            return Localize(@"Transfer");
           
        case 3:
            return Localize(@"AtmWithdraw");
            break;
        default:
            return @"?";
    }
}
NSMutableDictionary* sums;
-(void)updateSums:(Expense*)expense
{
    NSString* key = [NSString stringWithFormat:@"%i", expense.expenseType.intValue];
    double currentValue = ((NSNumber*)[sums valueForKey:key]).doubleValue;
    currentValue += expense.amount.doubleValue;
    [sums setValue:[NSNumber numberWithDouble:currentValue] forKey:key];
    
}
#pragma mark - Table view delegate
NSIndexPath* selectedRow;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedRow == nil || (selectedRow.row != indexPath.row && indexPath.section ==0))
    {   NSIndexPath* previous = selectedRow;
         selectedRow = indexPath;
        NSMutableArray* array = [NSMutableArray new];
        [array addObject:selectedRow];
        if (previous != nil)
            [array addObject:previous];
        
        [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
        //[tableView reloadInputViews];
    }
   
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Expense *t = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"Deleting (%@)", t.title);
        if (t.photoPath != nil)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:
                              t.photoPath];

            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
            
        [_managedObjectContext deleteObject:t];
        [_managedObjectContext save:nil];
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeDelete) {
        // Delete row from tableView.
       // [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
         //                     withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    } 
}


-(void)prepareFetchedResultsController
{
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:200];
    
    // Don't display unsaved cases
    [fetchRequest setIncludesPendingChanges:NO];
    [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"category",nil]];    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects: sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSMutableArray *paymentTypes = [NSMutableArray array];
    if (_cash)
    {
        [paymentTypes addObject:[NSNumber numberWithInt:0]];
    }
    if (_card)
    {
        [paymentTypes addObject:[NSNumber numberWithInt:1]];
    }
    if (_transfer)
    {
        [paymentTypes addObject:[NSNumber numberWithInt:2]];
    }
    if (_cashoutATM)
    {
        [paymentTypes addObject:[NSNumber numberWithInt:3]];
    }
    NSString* title = @"date >= %@ and date < %@ and expenseType in %@";
    if (_selectedTitle != nil)
    {
        title = @"date >= %@ and date < %@ and expenseType in %@ and category.name = %@";
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:title, _dateFrom, _dateTo, paymentTypes, _selectedTitle];
    [fetchRequest setPredicate:predicate];
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

- (IBAction)updateButtonClicked:(UIButton *)sender {
    ExpenseTableCell* cell = (ExpenseTableCell*)[self.tableView cellForRowAtIndexPath:selectedRow];
    Expense  *managedObject =
    (Expense*)[self.fetchedResultsController objectAtIndexPath:selectedRow];
    managedObject.amount = [NSDecimalNumber decimalNumberWithString:cell.amountTextField.text locale:[NSLocale currentLocale]];
    managedObject.title = cell.descriptionTextField.text;
    managedObject.date = _datePicker.date;
    
    //important! segment index ma znaczenie
    managedObject.expenseType = [NSNumber numberWithInt:cell.paymentTypeSegment.selectedSegmentIndex];
    managedObject.category = myBudgetCategories[selectedCategoryRow];
    [_managedObjectContext save:nil];
    
    UIAlertView *a = [[UIAlertView alloc]initWithTitle:Localize(@"Information") message:Localize(@"Updated") delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles: nil];
    [a show];


    
}

-(void)viewWillDisappear:(BOOL)animated
{
#ifdef FREE
    //banner
#endif
    [super viewWillDisappear:animated];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedRow == nil || (selectedRow.row != indexPath.row || selectedRow.section != indexPath.section))
    {
        if (indexPath.section == 1)
            return 41;
        Expense* ex= (Expense*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        if (ex.photoPath)
        {
            return 156;
        }
        return 66;
    }
    return 220;
    
}

UIDatePicker* _datePicker;
UITextField*  currentDateField;
-(void)dateChanged
{
    currentDateField.text = [dateFormatter stringFromDate:_datePicker.date];
}
UIImage* imageToPreview;
NSIndexPath *imageIndexPath;
NSString * imagePath;
- (IBAction)previewPictureClicked:(UIButton*)sender {
    imageToPreview = [sender backgroundImageForState:UIControlStateNormal];
    imagePath = [[images allKeysForObject:imageToPreview] firstObject];
    if (imagePath != nil && [images objectForKey:imagePath] != nil)
    {
        [images removeObjectForKey:imagePath];
    }

    
    [self performSegueWithIdentifier:@"ShowPreview" sender:self];
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    imageIndexPath = [self.tableView indexPathForRowAtPoint:hitPoint];
}

- (IBAction)categoryClicked:(UIButton *)sender {
    [sender setTitle:selectedTitle forState:UIControlStateNormal];
   
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPreview"] && imageToPreview != nil)
    {
        
        [segue.destinationViewController setupImage:imageToPreview named:imagePath];
    }
    if ([segue.identifier isEqualToString:@"ShowMap"] )
    {
        UIView *view = (UIView*)sender;
        ExpenseTableCell* cell;
        UIView* someView=  view.superview.superview;//[self.tableView cellForRowAtIndexPath:selectedRow];
        if ([someView respondsToSelector:@selector(lon)])
        {
            cell = (ExpenseTableCell*)someView;
        }
        else
        {
            cell = (ExpenseTableCell*)someView.superview;
        }
        
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        ExpenseMapViewController* controller = (ExpenseMapViewController*)segue.destinationViewController ;
        controller.lon = cell.lon;
        controller.lat = cell.lat;
        controller.expenseDescription = cell.title.text;
        controller.expenseTitle = cell.paymentType.text;
        controller.expenseCategory = cell.category.text;
    }
}
NSArray *myBudgetCategories;
-(void)loadCategories
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"BudgetCategory" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    myBudgetCategories = [moc executeFetchRequest:request error:&error];
    if ([myBudgetCategories count] >0)
    {
        selectedTitle = ((BudgetCategory*)myBudgetCategories[0]).name;
        selectedCategoryRow = 0;
    }
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [myBudgetCategories count];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return ((BudgetCategory*) myBudgetCategories[row]).name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedTitle =((BudgetCategory*) myBudgetCategories[row]).name;
    selectedCategoryRow = row;
}
- (IBAction)exportDataClicked:(id)sender {
    
    NSURL* url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/my-expenses-free-fast-expense/id694047068?ls=1&mt=8" relativeToURL:nil];
    NSMutableArray* sharingItems =  [[NSMutableArray alloc]init];
    
    [sharingItems addObject:url];
   
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSArray* data = [sectionInfo objects];
    for (int i = 0 ; i < data.count ; ++i)
    {
        Expense* e = [data objectAtIndex:i];
        [sharingItems addObject:e];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    activityController.excludedActivityTypes=[NSArray arrayWithObjects:UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToVimeo, nil];
    
    [self presentViewController:activityController animated:YES completion:nil];
   

    
}

@end
