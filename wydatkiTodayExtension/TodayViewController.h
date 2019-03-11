//
//  TodayViewController.h
//  wydatkiTodayExtension
//
//  Created by jarek on 13.10.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *suggestedExpenseButton;
@property (weak, nonatomic) IBOutlet UIButton *otherExpense;
- (IBAction)addSuggested:(UIButton *)sender;
- (IBAction)addOther:(UIButton *)sender;

@end
