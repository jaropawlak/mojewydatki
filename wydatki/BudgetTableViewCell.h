//
//  BudgetTableViewCell.h
//  wydatki
//
//  Created by Jarosław Pawlak on 18.06.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BudgetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@end
