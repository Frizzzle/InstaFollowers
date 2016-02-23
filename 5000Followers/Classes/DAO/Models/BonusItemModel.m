//
//  BonusItemModel.m
//  5000Followers
//
//  Created by Koctya on 1/7/16.
//  Copyright © 2016 Pro.Code. All rights reserved.
//

#import "BonusItemModel.h"
#import "Managers.h"
#import "bonusRewardModel.h"

@interface BonusItemModel ()
@property NSTimer* timer;
@end

@implementation BonusItemModel
- (id) init {
    self = [super init];
    if(self){
        self.requiredLevel = 0;
        self.timerCell = nil;
        self.timerSeconds = 0;
    }
    return self;
}

-(void) reloadBonus {
    [self.timer invalidate];
    if(self.timerSeconds < 1) {
        self.timerSeconds = TIME_SEC_IN_DAY;
    }
    self.isActive = true;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(targetMethod:)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)setTimerSec {
    NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
    [df setDateFormat:@"HH:mm"];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSTimeInterval interval = [self.date timeIntervalSinceDate:[NSDate date]];
    int dayDelta = TIME_SEC_IN_DAY + (int)interval;
    self.timerSeconds = dayDelta;

}

- (id)initWithRequiredLevel:(NSInteger) requiredLevel  timerCell:(BonusTVC*) timerCell date:(NSDate*) createAt {
    self = [self init];
    self.requiredLevel = requiredLevel;
    self.timerCell = timerCell;
    self.date = createAt;
    [self setTimerSec];
    if(requiredLevel == 2) {
        
    }
    self.isActive = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(targetMethod:)
                                   userInfo:nil
                                    repeats:YES];
    
    if (self.timerSeconds < 1) {
        self.isActive = NO;
    }else {
        self.isActive = YES;
    }
    
    return self;
}

- (void)targetMethod:(NSTimer*)theTimer {
    self.timerSeconds--;
    if(self.timerSeconds < 1) {
        [[BonusManager sharedManager] refreshRewardWithRequiredLevel:(int) self.requiredLevel];
        self.timerSeconds = 0;
        self.isActive = NO;
        [self.timer invalidate];
        self.timerCell.maskLbl.hidden = YES;
        self.timerCell.rewardLbl.hidden = NO;
        self.timerCell.coinsIcon.hidden = NO;
        self.timerCell.subtitleLbl.text = [NSString stringWithFormat:str_TTCR];

    }else {
        if(self.timerCell != nil) {
            int hours = (int)self.timerSeconds / 3600;
            int minutes = (int)((self.timerSeconds - (hours*3600)) / 60);
            int sec = self.timerSeconds % 60;
            self.timerCell.maskLbl.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,sec];
        }
 
    }
}
@end
