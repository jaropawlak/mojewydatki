//
//  NewExpenseController.h
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Expense.h"
#import <CoreLocation/CoreLocation.h>

#import "AdViewController.h"
#import "SZTextView.h"

@interface NewExpenseController : AdViewController<UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate,NSFetchedResultsControllerDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UILabel *awesomeLabelAmount;
@property (weak, nonatomic) IBOutlet UILabel *awesomeLabelDescription;
@property (weak, nonatomic) IBOutlet UILabel *awesomeExpenseType;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *historyBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *budgetsBarButton;

@property NSManagedObjectContext *managedObjectContext;
- (IBAction)addPhotoClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet SZTextView *amountTextView;
@property (weak, nonatomic) IBOutlet SZTextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@property (weak, nonatomic) IBOutlet UIButton *expenseTypeButton;


@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)addExpense:(id)sender;
//Labels


@property (weak, nonatomic) IBOutlet UIPickerView *expenseTypePicker;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *addExpenseButton;

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
- (IBAction)clearImage:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
- (IBAction)selectCategory:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITableView *budgetTableView;

@property (weak, nonatomic) IBOutlet UIButton *categoryLabelButton;



-(void)clearFields;
@end
