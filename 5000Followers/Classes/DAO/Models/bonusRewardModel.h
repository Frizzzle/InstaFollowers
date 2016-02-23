//
//  bunusRewardModel.h
//  5000Followers
//
//  Created by Koctya on 12/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface bonusRewardModel : NSObject
@property  NSString* objectId;
@property  NSInteger requiredLevel;
@property  NSInteger reward;
@property  NSDate* createAt;

- (id)initWithObjectId:(NSString*) objectId requiredLevel:(NSInteger) requiredLevel  reward:(NSInteger) reward createAt:(NSDate*) createAt;
@end
