//
//  buyCoins.h
//  5000Followers
//
//  Created by Koctya on 11/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface buyCoinsModel : NSObject
@property  NSString* objectId;
@property  NSString* inapp_id;
@property  NSInteger coins;
@property  NSInteger bonus;
@property  BOOL isBonusEnabled;
@property  BOOL isMostPopular;
@property  BOOL isBestValue;

@property  NSString* price;

- (id)initWithObjectId:(NSString*) objectId inapp_id:(NSString*) inapp_id
                 coins:(NSInteger) coins
                 bonus:(NSInteger) bonus
        isBonusEnabled:(BOOL) isBonusEnabled
         isMostPopular:(BOOL) isMostPopular
           isBestValue:(BOOL) isBestValue;
-(void) setCoinsPrice:(NSString*) price;
@end
