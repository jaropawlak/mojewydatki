//
//  ExpenseTableCell.m
//  wydatki
//
//  Created by jarek on 5/28/13.
//  Copyright (c) 2013 majatech. All rights reserved.
//

#import "ExpenseTableCell.h"

@implementation ExpenseTableCell


BOOL isShowingCategoryPicker = NO;
- (IBAction)categoryButtonClicked:(UIButton *)sender {
    isShowingCategoryPicker = !isShowingCategoryPicker;
    [_categoryPicker setHidden:!isShowingCategoryPicker];
    if (!isShowingCategoryPicker)
    {
       
    }
}
@end
