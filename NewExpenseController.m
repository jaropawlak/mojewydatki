//
//  NewExpenseController.m
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import "NewExpenseController.h"
#import "ShowHistoryControllerViewController.h"
#import "BudgetViewController.h"

#import <Social/Social.h>
#import "AppDelegate.h"
#import "BudgetCategory.h"
#import "NSDate+Reporting.h"


#import "UIView+Toast.h"
#import "UIView+Animations.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"

@interface NewExpenseController()
@property CLLocationManager *locationManager;

@end

@implementation NewExpenseController
BOOL expenseTypeEditing = false;
NSDateFormatter *dateFormatter;
NSString *selectedTitle;
int selectedCategoryRowId=0;
BOOL userDidManuallyChangeCategory = NO;
BOOL setCategoryAutomatically = YES;
-(void)displayWhatsNew
{
    NSString* version = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *savedVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"whatsnewversion"];
    
    if (![version isEqualToString:savedVersion])
    {
        //display whats new
        [[[UIAlertView alloc] initWithTitle:Localize(@"What's new")
                                    message:Localize(@"What's new in this version")
                                   delegate:nil
                          cancelButtonTitle:Localize(@"OK")
                          otherButtonTitles:nil]
         show];
        
        [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"whatsnewversion"];
    }
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.awesomeLabelAmount.text = [NSString fontAwesomeIconStringForEnum:FAMoney];
    self.awesomeLabelDescription.text = [NSString fontAwesomeIconStringForEnum:FAFileTextO];
    self.awesomeExpenseType.text = [NSString fontAwesomeIconStringForEnum:FAbank];
    self.dateLabel.text = [NSString fontAwesomeIconStringForEnum:FAClockO];
    [self.categoryLabelButton setTitle:[NSString fontAwesomeIconStringForEnum:FATag]
                              forState:UIControlStateNormal];
    [self.budgetsBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontAwesomeFontOfSize:18.0], NSFontAttributeName,
                                        self.view.tintColor, NSForegroundColorAttributeName,
                                        nil] 
                              forState:UIControlStateNormal];
    self.budgetsBarButton.title = [NSString fontAwesomeIconStringForEnum:FATags];
    if (!self.managedObjectContext)
    {
        AppDelegate* app =(AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = app.managedObjectContext;
    }
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    _dateText.inputView = _datePicker;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSLocale* locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];

     
    _dateText.text = [dateFormatter stringFromDate:_datePicker.date];
    
    self.title = Localize(@"NewExpense");
//    self.amountTextView.placeholder=Localize(@"Amount");
//    self.titleTextView.placeholder = Localize(@"Description");
    self.amountTextField.placeholder=Localize(@"Amount");
    self.descriptionTextField.placeholder = Localize(@"Description");

//    self.dateLabel.text = Localize(@"Date");
    [self.addExpenseButton setTitle:Localize(@"AddExpense") forState:UIControlStateNormal];
    [self.clearButton setTitle:Localize(@"Clear") forState:UIControlStateNormal];
       [self.categoryButton setTitle:Localize(@"Category") forState:UIControlStateNormal];
    [self.expenseTypeButton setTitle:Localize(@"Cash") forState:UIControlStateNormal];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissInputs)];
    
    [self.view addGestureRecognizer:tap];
    
    _locationManager = [[CLLocationManager alloc] init];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager  requestWhenInUseAuthorization];
    }
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 0.2;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
   

    [self displayWhatsNew];
    self.navigationItem.leftBarButtonItems = @[_historyBarButton, _budgetsBarButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCategories) name:@"REFRESH_CATEGORIES" object:nil];
}
-(void)dismissInputs
{
    [self dismissKeyboard];
    [_categoryPicker setHidden:YES];
    [_expenseTypePicker setHidden:YES];
}
-(void)dismissKeyboard {
//    [self.amountTextView resignFirstResponder];
//     [self.titleTextView resignFirstResponder];
    [self.amountTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
     [self.dateText resignFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    userDidManuallyChangeCategory = NO;
    setCategoryAutomatically = YES;
    [self loadCategories];
   
    [self prepareFetchedResultsController];
    [_budgetTableView reloadData];
    [self dismissKeyboard];

}
NSArray *budgetCategories;
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
    budgetCategories = [moc executeFetchRequest:request error:&error];
    if ([budgetCategories count] >0)
    {
        selectedTitle = ((BudgetCategory*)budgetCategories[0]).name;
        [self.categoryButton setTitle:selectedTitle forState:UIControlStateNormal];
        selectedCategoryRowId = 0;
    }
    [_categoryPicker reloadAllComponents];
}
-(void)dateChanged
{
    _dateText.text = [dateFormatter stringFromDate:_datePicker.date];
}

- (IBAction)addExpense:(id)sender {
    BOOL validationFailed = NO;
    if (_amountTextField.text.doubleValue ==0)
    {
        [_amountTextField shake];
        validationFailed = YES;
    }
    if ((_descriptionTextField.text.length ==0 && selectedTitle.length == 0  )&& image == nil)
    {
        [_descriptionTextField shake];
        validationFailed = YES;
        
    }
    if (validationFailed)
    {
        return;
    }
    
    
    Expense *newExpense = [NSEntityDescription insertNewObjectForEntityForName:@"Expense" inManagedObjectContext:_managedObjectContext];
    
    newExpense.amount = [NSDecimalNumber decimalNumberWithString:_amountTextField.text locale:[NSLocale currentLocale]];
    newExpense.title = _descriptionTextField.text;
    newExpense.date = _datePicker.date;
    newExpense.lon = [NSNumber numberWithDouble:lon];
    newExpense.lat = [NSNumber numberWithDouble:lat];
    //important! segment index ma znaczenie
    newExpense.expenseType = [NSNumber numberWithInt:expenseTypeId];
    if (budgetCategories != nil)
    {
        if (selectedTitle != nil)
        {
            newExpense.category = budgetCategories[selectedCategoryRowId];
        }
    }
    NSString* imagePath = nil;
    if (image != nil)
    {
        imagePath = [self saveImage];
        newExpense.photoPath = imagePath;
    }
    
    [_managedObjectContext save:nil];
    [self prepareFetchedResultsController];
    [_budgetTableView reloadData];
    [self clearFields];
    Toast(Localize(@"EntryAdded"));
        
}
- (IBAction)expenseTypeAction:(UIButton *)sender {
    [self dismissKeyboard];
    if (isShowingCategory)
    {
        [self selectCategory:sender];
    }
    expenseTypeEditing = !expenseTypeEditing;
    [_expenseTypePicker setHidden:!expenseTypeEditing];
    
}

-(NSString*)saveImage
{
    if (image!= nil)
    {
        //generate name
        NSString* key = [[NSUUID UUID] UUIDString];
        NSString* fileName = [NSString stringWithFormat:@"%@.png", key];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          fileName ];
        //scale image
        CGSize size =CGSizeMake(image.size.width/2, image.size.height/2);
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0,0,size.width,size.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        
        NSData* data = UIImageJPEGRepresentation(newImage, 0.9f);
        [data writeToFile:path atomically:YES];
         return fileName;
       
    }
    return @"";
}

NSNumberFormatter *numberFormatter;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _dateText)
    {
        return NO;
    }
    if (textField == _amountTextField)
    {
        
        NSString* x= [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (x.length ==0)
            return YES;
        
        if (!numberFormatter) {
            numberFormatter = [[NSNumberFormatter alloc]init];
            //[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            
        }
        NSNumber *test = [numberFormatter numberFromString:x];
        
        if (test == nil) return NO;
        NSArray *sep = [x componentsSeparatedByString:@"."];
        if (sep.count ==2)
        {
            x = sep[1];
            if (x.length >2) return NO;
        }
    }

    return YES;
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
        if (textView == _amountTextView)
        {
    
            NSString* x= [textView.text stringByReplacingCharactersInRange:range withString:text];
            if (x.length ==0)
                return YES;
    
            if (!numberFormatter) {
                numberFormatter = [[NSNumberFormatter alloc]init];
                //[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
            }
            NSNumber *test = [numberFormatter numberFromString:x];
    
            if (test == nil) return NO;
            NSArray *sep = [x componentsSeparatedByString:@"."];
            if (sep.count ==2)
            {
                x = sep[1];
                if (x.length >2) return NO;
            }
        }
    return YES;
 
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setManagedObjectContext:_managedObjectContext];
   
}
- (IBAction)clearImage:(id)sender {
    _imagePreview.image = nil;
    image = nil;
    [_clearButton setHidden:YES];
        [self resizeTableForImageShown:NO];
}
BOOL isShowingCategory = NO;
- (IBAction)selectCategory:(UIButton *)sender {
    [self dismissKeyboard];
    if (expenseTypeEditing)
    {
        [self expenseTypeAction:sender];
    }
    isShowingCategory = !isShowingCategory;
    
    [self.categoryPicker setHidden:!isShowingCategory];
    
   
    [self resizeTableForImageShown:NO];
}
-(void)resizeTableForImageShown:(BOOL)imageVisible
{
    CGRect newFrame = _budgetTableView.frame;
    
    if (imageVisible)
    {
        // height to bottom of image
        float newY = _imagePreview.frame.origin.y + _imagePreview.frame.size.height;
        float newHeight = self.view.frame.size.height - newY;
        newFrame = CGRectMake(newFrame.origin.x, newY, newFrame.size.width, newHeight);
        
    }
    else
    {
        float newY = _dateText.frame.origin.y + _dateText.frame.size.height;
        float newHeight = self.view.frame.size.height - newY;
        newFrame = CGRectMake(newFrame.origin.x, newY, newFrame.size.width, newHeight);
        
    }

    [UIView animateWithDuration:0.75 animations:^{
        _budgetTableView.frame = newFrame;
    }];
}
-(void)clearFields
{
//    _amountTextView.text = @"";
//    _titleTextView.text = @"";
    _amountTextField.text = @"";
    _descriptionTextField.text = @"";
    
    _datePicker.date = [NSDate date];
    
    image = nil;
    _imagePreview.image = nil;
    [_clearButton setHidden:YES];
    [self dateChanged];
}
- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setDateLabel:nil];
    [self setAddExpenseButton:nil];
    [super viewDidUnload];
}
- (IBAction)addPhotoClicked:(id)sender {
        BOOL isPhotoAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ];
    BOOL isLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (isPhotoAvailable && isLibraryAvailable)
    {
        NSString* photo = Localize(@"Photo");
        NSString* library = Localize(@"Library");
        UIActionSheet *chooseSource = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"chooseInput", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:library,photo,nil];
        [chooseSource showFromRect:self.addPhotoButton.frame inView:self.addPhotoButton animated:YES];
        
    }
    else if (isLibraryAvailable)
    {
        [self usePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
        
    
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSURL* url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/my-expenses-free-fast-expense/id694047068?ls=1&mt=8" relativeToURL:nil];
        NSMutableArray* sharingItems =  [[NSMutableArray alloc]init];
        
        [sharingItems addObject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"LookWhatIBought", nil) , _titleTextView.text]];
        [sharingItems addObject:url];
        if (image != nil)
        {
            NSString* stringToEncode = @"http://bit.ly/myexpenses";
            
            UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
            [image drawAtPoint:CGPointZero];
            
           
            UIFont *captionFont = [UIFont boldSystemFontOfSize:40.0];
            [[UIColor whiteColor] setFill];
            [stringToEncode drawAtPoint:CGPointMake(10.0f, 10.0f) withFont:captionFont];
            
            UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [sharingItems addObject:resultImage];
        }
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];

        activityController.excludedActivityTypes=[NSArray arrayWithObjects:UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToVimeo, nil];
//        [[self amountTextView] resignFirstResponder];
//        [[self titleTextView] resignFirstResponder];
        [[self amountTextField] resignFirstResponder];
        [[self descriptionTextField] resignFirstResponder];
          [self presentViewController:activityController animated:YES completion:nil];
        
           }
    else
    {
#ifdef FREE
          //banner!
#endif
            
    }
    [self clearFields];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1 )
    {
        [self usePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
    else if (buttonIndex == 0)
    {
        [self usePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}
-(void)usePickerWithType:(UIImagePickerControllerSourceType) sourceType
{
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
   
}

UIImage* image;
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = (UIImage*)[info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
    {
        image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    }
    self.imagePreview.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_clearButton setHidden:NO];
    [self resizeTableForImageShown:YES];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker)
    {
    return [budgetCategories count];
    }
    else return 4;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker)
    {
        return ((BudgetCategory*) budgetCategories[row]).name;
    }
    else if (pickerView == _expenseTypePicker)
    {
        switch (row)
        {
            case 0: return Localize(@"Cash");
            case 1: return Localize(@"Card");
            case 2: return Localize(@"Transfer");
            case 3: return Localize(@"AtmMachine");
        }
    }
    return @"";
}
int expenseTypeId = 0;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker)
    {
    selectedTitle =((BudgetCategory*) budgetCategories[row]).name;
    selectedCategoryRowId = row;
    userDidManuallyChangeCategory = YES;
        [self.categoryButton setTitle:selectedTitle forState:UIControlStateNormal];
    }
    else if (pickerView == _expenseTypePicker)
    {
        expenseTypeId = row;
        [_expenseTypeButton setTitle:[self pickerView:_expenseTypePicker titleForRow:row forComponent:component ] forState:UIControlStateNormal];
    }
}

#pragma mark table view


-(void)prepareFetchedResultsController
{
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Expense" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *sumPredicate = [NSPredicate predicateWithFormat:@" (%@ <= date AND date <= %@)",
                                 [NSDate firstDayOfCurrentMonth], [NSDate firstDayOfNextMonth]];
    
    fetchRequest.predicate = sumPredicate;
    [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"category",nil]];
    
    NSExpressionDescription* ex = [[NSExpressionDescription alloc] init];
    [ex setExpression:[NSExpression expressionWithFormat:@"@sum.amount"]];
    [ex setExpressionResultType:NSDecimalAttributeType];
    ex.name = @"SumExpenses";
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"category.name",@"category.budget",ex, nil]];
    [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:@"category.name",@"category.budget",nil]];
    [fetchRequest setResultType:NSDictionaryResultType ];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
      NSError *error = nil;
     NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath: nil cacheName: nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return Localize(@"Budget categories");
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"BudgetLimitCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary  *managedObject =
    (NSDictionary*)[self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = [managedObject valueForKeyPath:@"category.name"];
    NSNumber *budget =[managedObject valueForKeyPath:@"category.budget"];
    NSNumber *expenseSum =  [managedObject valueForKeyPath:@"SumExpenses"];
   
    if (budget.floatValue > expenseSum.floatValue)
    {
        if (budget.floatValue * 3 < expenseSum.floatValue * 4)
        {
             cell.detailTextLabel.textColor = [UIColor orangeColor];
        }
        else
        {
            cell.detailTextLabel.textColor = [UIColor greenColor];
        }
    }
    else
    {
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    NSDecimalNumber *d =(NSDecimalNumber*)[managedObject valueForKeyPath:@"SumExpenses"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",d ];

    return cell;
}
#pragma mark location related
double lat, lon;
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    lat = newLocation.coordinate.latitude;
    lon = newLocation.coordinate.longitude;
    if (setCategoryAutomatically && !userDidManuallyChangeCategory)
    {
        [self findClosestCategory];
        setCategoryAutomatically = NO;
    }
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
   
        lat = location.coordinate.latitude;
        lon = location.coordinate.longitude;
        if (setCategoryAutomatically && !userDidManuallyChangeCategory)
        {
            [self findClosestCategory];
            setCategoryAutomatically = NO;
        }
}

//mark: location to closest category

//todo: zawołaj to jeśli 1. user sam nie wybrał kategorii, 2. mamy już dokładną lokalizację, 3. tylko raz
-(void)findClosestCategory
{
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
        int i = 0 ;
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
        }

    }
    
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
 //   [textView scrollRangeToVisible:textView.selectedRange];
}
@end
