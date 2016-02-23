//
//  TapJoyManager.h
//  5000Followers
//
//  Created by Koctya on 2/1/16.
//  Copyright © 2016 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Tapjoy/Tapjoy.h>
@interface TapJoyManager : NSObject
+ (TapJoyManager *) sharedManager;

-(void) synchronizeCoinsOnTapJoy;

-(void) getEarnedDeltaWithCompletion:(void(^) (int earnedCount)) callback;

@end
