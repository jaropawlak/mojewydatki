//
//  ShowHistoryControllerViewController.m
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import "ShowHistoryControllerViewController.h"
#import "ExpensesTableViewController.h"
#import "BudgetCategory.h"
#import "NSDate+Reporting.h"
#import "NSString+FontAwesome.h"

@interface ShowHistoryControllerViewController ()
@property NSMutableArray *budgetCategories;
@end

@implementation ShowHistoryControllerViewController
UIDatePicker *_datePicker;
NSDateFormatter *dateFormatter;
NSDate *dateFrom, *dateTo;

NSString* selectedTitle;

-(void)loadCategories
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"BudgetCategory" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPropertiesToFetch:@[@"name"]];
    [request setResultType:NSDictionaryResultType];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
     _budgetCategories =[NSMutableArray arrayWithArray:[[moc executeFetchRequest:request error:&error] valueForKey:@"name"]];
    for (int i = 0 ; i < _budgetCategories.count ; ++i)
    {
        if (_budgetCategories[i] == nil || [_budgetCategories[i] class] == [NSNull class])
        {
            _budgetCategories[i] = @"?";
        }
    }
    [_budgetCategories insertObject:Localize(@"All") atIndex:0];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    
    _dateFromText.inputView = _datePicker;
    _dateToText.inputView = _datePicker;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSLocale* locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [self loadCategories];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
        dateTo = [NSDate date];
    dateFrom = [NSDate firstDayOfCurrentMonth];
//    dateFrom =[dateTo dateByAddingTimeInterval:- (60*60*24*7)];
    
    _dateFromText.text = [dateFormatter stringFromDate:dateFrom];
    _dateToText.text = [dateFormatter stringFromDate:dateTo];
    
   // _dateText.text = [dateFormatter stringFromDate:_datePicker.date];
    _fromLabel.text = [NSString fontAwesomeIconStringForEnum:FAStepBackward]; //Localize(@"From");
    _toLabel.text = [NSString fontAwesomeIconStringForEnum:FAStepForward];//Localize(@"To");
    _expenseTypeFilterLabel.text = Localize(@"ExpenseTypeFilterLabel");
    
    _cashLabel.text = Localize(@"Cash");
    _cardPaymentLabel.text = Localize(@"Card");
    _transferlabel.text = Localize(@"Transfer");
    _atmMachineLabel.text = Localize(@"AtmMachine");
    [_searchButton setTitle:Localize(@"SearchExpenses") forState:UIControlStateNormal];
    self.title = Localize(@"SavedExpenses");
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissInputs)];
    
    [self.view addGestureRecognizer:tap];
    
}
-(void)dismissInputs
{
    [_dateFromText resignFirstResponder];
    [_dateToText resignFirstResponder];
}
-(void)dateChanged
{
    if ([_dateFromText isFirstResponder])
    {
        _dateFromText.text = [dateFormatter stringFromDate:_datePicker.date];
        dateFrom = _datePicker.date;
    }
    else if ([_dateToText isFirstResponder])
    {
        _dateToText.text = [dateFormatter stringFromDate:_datePicker.date];
        dateTo = _datePicker.date;
    }
        
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}
- (IBAction)dateTextStartEditing:(UITextField *)sender {
    if (sender == _dateFromText)
    {
        _datePicker.date = dateFrom;
    }
    else
    {
        _datePicker.date = dateTo;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
      ExpensesTableViewController *d = (ExpensesTableViewController*)segue.destinationViewController;
    d.dateFrom = dateFrom;
    d.dateTo = dateTo;
    d.cash = _cashSwitch.on;
    d.card = _cardSwitch.on;
    d.cashoutATM = _atmSwitch.on;
    d.transfer = _transferSwitch.on;
    d.managedObjectContext = _managedObjectContext;
    int row = [_categoryPickerView selectedRowInComponent:0];
    if ( row!= 0)
    {
        d.selectedTitle = _budgetCategories[row];
    }
    else
    {
        d.selectedTitle = nil;
    }
    
}
- (void)viewDidUnload {
    [self setFromLabel:nil];
    [self setToLabel:nil];
    [self setExpenseTypeFilterLabel:nil];
    [self setCashLabel:nil];
    [self setAtmMachineLabel:nil];
    [self setCardPaymentLabel:nil];
    [self setTransferlabel:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_budgetCategories count];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _budgetCategories[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedTitle =_budgetCategories[row];
    
}

@end
