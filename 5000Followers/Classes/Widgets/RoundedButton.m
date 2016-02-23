//
//  RoundedButton.m
//
//
//  Created by Alexandr Chernyy on 11/1/15.
//  Copyright © 2015 Pro.Code LLC. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton
@synthesize roundedSize;


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.cornerRadius = roundedSize;
    self.clipsToBounds = true;
}

@end
