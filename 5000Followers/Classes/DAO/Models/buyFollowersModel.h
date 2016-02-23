//
//  buyFollowersModel.h
//  5000Followers
//
//  Created by Koctya on 11/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface buyFollowersModel : NSObject
@property  NSString* objectId;
@property  NSInteger followers;
@property  NSInteger coins;
@property  NSInteger bonus;
@property  BOOL isBonusEnabled;

- (id)initWithObjectId:(NSString*) objectId followers:(NSInteger) followers
                 coins:(NSInteger) coins
                 bonus:(NSInteger) bonus
        isBonusEnabled:(BOOL) isBonusEnabled;
@end
