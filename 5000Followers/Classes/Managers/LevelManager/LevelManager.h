//
//  LevelManager.h
//  5000Followers
//
//  Created by Koctya on 12/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelManager : NSObject
+ (LevelManager *) sharedManager;
@property int userLevel;
@property int userRemainFollowers;
-(void) loadUserLevel;
-(void) decreaseRemainFollowers;
-(void) logoutAction;
@end
