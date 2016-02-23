//
//  BonusManager.m
//  5000Followers
//
//  Created by Koctya on 12/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "BonusManager.h"
#import "Managers.h"
#import "bonusRewardModel.h"

@implementation BonusManager
+ (BonusManager*) sharedManager {
    
    static BonusManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BonusManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.userRewards = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void) logoutAction {
    self.userRewards = [[NSMutableArray alloc] init];
}

-(void) loadRewards {
    PFQuery* userReward = [[PFQuery alloc] initWithClassName:USER_LEVEL_REWARDS_CLASS];
    [userReward whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userReward includeKey:REWARD_ID_FIELD];
    [userReward findObjectsInBackgroundWithBlock:^(NSArray* _Nullable objects, NSError * _Nullable error) {
        if(error == nil) {
            for (PFObject* item in objects) {
                PFObject* object = [item objectForKey:REWARD_ID_FIELD];
                int requiredLevel = (int)[object[REQUIRED_LEVEL_FIELD] integerValue];
                int reward = (int)[object[REWARD_FIELD] integerValue];
                NSDate* createDate = [item createdAt];
                NSTimeInterval interval = [createDate timeIntervalSinceDate:[NSDate date]];
                if(((int) interval + TIME_SEC_IN_DAY) < 0 ) {
                    [item deleteInBackground];
                    continue;
                }
                [self.userRewards addObject: [[bonusRewardModel alloc] initWithObjectId:object.objectId requiredLevel:requiredLevel reward:reward createAt:createDate] ];
            }
        }
    }];
}
-(void) refreshRewardWithRequiredLevel:(int) requiredLevel {
    PFQuery* userReward = [[PFQuery alloc] initWithClassName:USER_LEVEL_REWARDS_CLASS];
    [userReward whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userReward includeKey:REWARD_ID_FIELD];
    [userReward findObjectsInBackgroundWithBlock:^(NSArray* _Nullable objects, NSError * _Nullable error) {
        if(error == nil) {
            for (PFObject* item in objects) {
                PFObject* object = [item objectForKey:REWARD_ID_FIELD];
                int required = (int)[object[REQUIRED_LEVEL_FIELD] integerValue];
                if(requiredLevel == required) {
                    [item deleteInBackground];
                    for (bonusRewardModel* item  in self.userRewards) {
                        [self.userRewards removeObject:item];
                        return;
                    }

                }

            }
        }
    }];
}
     
-(void) receiveReward:(PFObject* ) reward onFinish:(void(^) ()) finish {
    PFObject* newReward = [[PFObject alloc] initWithClassName:USER_LEVEL_REWARDS_CLASS];
    newReward[USER_ID] = [PFUser currentUser];
    newReward[REWARD_ID_FIELD] = reward;
    [newReward saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        int requiredLevel = (int)[reward[REQUIRED_LEVEL_FIELD] integerValue];
        int rewardValue = (int)[reward[REWARD_FIELD] integerValue];
        NSDate* createDate = [newReward createdAt];
        
        [self.userRewards addObject: [[bonusRewardModel alloc] initWithObjectId:reward.objectId requiredLevel:requiredLevel reward:rewardValue createAt:createDate] ];
        finish();
    }];
    
}

@end
