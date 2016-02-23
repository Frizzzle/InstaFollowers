//
//  BonusManager.h
//  5000Followers
//
//  Created by Koctya on 12/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface BonusManager : NSObject
+ (BonusManager *) sharedManager;

@property NSMutableArray* userRewards;
@property NSMutableArray* levelRewards;
-(void) loadRewards;
-(void) receiveReward:(PFObject* ) rewardId onFinish:(void(^) ()) finish;
-(void) refreshRewardWithRequiredLevel:(int) requiredLevel;
-(void) logoutAction;
@end
