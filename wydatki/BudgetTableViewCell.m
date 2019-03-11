//
//  BudgetTableViewCell.m
//  wydatki
//
//  Created by Jarosław Pawlak on 18.06.2014.
//  Copyright (c) 2014 majatech. All rights reserved.
//

#import "BudgetTableViewCell.h"

@implementation BudgetTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
