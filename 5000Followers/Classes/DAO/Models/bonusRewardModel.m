//
//  bunusRewardModel.m
//  5000Followers
//
//  Created by Koctya on 12/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "bonusRewardModel.h"

@implementation bonusRewardModel
- (id) init {
    self = [super init];
    if(self){
        self.objectId = nil;
        self.requiredLevel = 0;
        self.reward = 0;
        self.createAt = nil;
    }
    return self;
}

- (id)initWithObjectId:(NSString*) objectId requiredLevel:(NSInteger) requiredLevel  reward:(NSInteger) reward createAt:(NSDate*) createAt {
    self = [self init];
    self.objectId = objectId;
    self.requiredLevel = requiredLevel;
    self.reward = reward;
    self.createAt = createAt;
    return self;
}
@end
