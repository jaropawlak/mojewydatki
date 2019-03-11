//
//  UIVIew+Animations.m
//  wydatki
//
//  Created by Jarosław Pawlak on 03.04.2015.
//  Copyright (c) 2015 majatech. All rights reserved.
//

#import "UIView+Animations.h"

@implementation UIView (Animations)
-(void)shake
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values = @[ @0, @15, @-12, @6, @0 ];
    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
    animation.duration = 0.45;
    animation.timingFunction = [CAMediaTimingFunction
                                functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.additive = YES;
        
    [self.layer addAnimation:animation forKey:@"shake"];
    
}
@end
