//
//  buyFollowersModel.m
//  5000Followers
//
//  Created by Koctya on 11/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "buyFollowersModel.h"

@implementation buyFollowersModel

- (id) init {
    self = [super init];
    if(self){
        self.objectId = nil;
        self.followers = 0;
        self.coins = 0;
        self.bonus = 0;
        self.isBonusEnabled = nil;
    }
    return self;
}

- (id)initWithObjectId:(NSString*) objectId followers:(NSInteger) followers
                 coins:(NSInteger) coins
                 bonus:(NSInteger) bonus
        isBonusEnabled:(BOOL) isBonusEnabled{
    self = [self init];
    self.objectId = objectId;
    self.followers = followers;
    self.coins = coins;
    self.bonus = bonus;
    self.isBonusEnabled = isBonusEnabled;
    return self;
}
@end
