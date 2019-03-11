//
//  ExpenseTableCell.h
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpenseTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *paymentType;
@property (weak, nonatomic) IBOutlet UILabel *title;
//Labels
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToLocation;

//Editor settings
@property (weak, nonatomic) IBOutlet UISegmentedControl *paymentTypeSegment;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
- (IBAction)categoryButtonClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *imagePreviewButton;

@property double lat;
@property double lon;
@end
