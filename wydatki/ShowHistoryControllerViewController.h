//
//  ShowHistoryControllerViewController.h
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface ShowHistoryControllerViewController : UIViewController
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextField *dateFromText;
@property (weak, nonatomic) IBOutlet UITextField *dateToText;
- (IBAction)dateTextStartEditing:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *cashSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *atmSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *transferSwitch;
//Labels
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *expenseTypeFilterLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashLabel;
@property (weak, nonatomic) IBOutlet UILabel *atmMachineLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardPaymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *transferlabel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPickerView;



@end
