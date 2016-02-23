//
//  buyCoins.m
//  5000Followers
//
//  Created by Koctya on 11/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "buyCoinsModel.h"
#include "Constants.h"

@implementation buyCoinsModel
- (id) init {
    self = [super init];
    if(self){
        self.objectId = nil;
        self.inapp_id = nil;
        self.coins = 0;
        self.bonus = 0;
        self.price = str_no_price;
    }
    return self;
}

- (id)initWithObjectId:(NSString*) objectId inapp_id:(NSString*) inapp_id
                 coins:(NSInteger) coins
                 bonus:(NSInteger) bonus
        isBonusEnabled:(BOOL) isBonusEnabled
         isMostPopular:(BOOL) isMostPopular
           isBestValue:(BOOL) isBestValue{
    self = [self init];
    self.objectId = objectId;
    self.inapp_id = inapp_id;
    self.coins = coins;
    self.bonus = bonus;
    self.isBonusEnabled = isBonusEnabled;
    self.isMostPopular = isMostPopular;
    self.isBestValue = isBestValue;
    return self;
}
-(void) setCoinsPrice:(NSString*) price {
    self.price = price;
}

@end
