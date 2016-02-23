//
//  BonusItemModel.h
//  5000Followers
//
//  Created by Koctya on 1/7/16.
//  Copyright © 2016 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include "BonusTVC.h"
@interface BonusItemModel : NSObject
@property  NSInteger requiredLevel;
@property  BonusTVC* timerCell;
@property  NSInteger timerSeconds;
@property  BOOL isActive;
@property  NSDate* date;

-(void) reloadBonus;

- (id)initWithRequiredLevel:(NSInteger) requiredLevel  timerCell:(BonusTVC*) timerCell date:(NSDate*) createAt;

@end
