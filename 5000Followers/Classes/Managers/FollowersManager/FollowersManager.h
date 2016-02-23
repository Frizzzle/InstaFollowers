//
//  FollowersManager.h
//  5000Followers
//
//  Created by Koctya on 11/28/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "followersModel.h"
#import <Parse/Parse.h>

@interface FollowersManager : NSObject
+ (FollowersManager *) sharedManager;
@property NSMutableArray* followers;
@property NSMutableArray* userFollowings;
@property int updateState;

-(void) addUserToFollowersWithId:(NSString*) instagram_id countFollowers:(NSInteger) countFollowers onSuccess: (void(^) ()) success onFailure:(void(^) (NSError*)) failure;

-(void) getFollowersonSuccess: (void(^) (NSMutableArray*)) success;
-(void) getFollowerDetails:(followersModel*) detailUser withCallback: (void(^) (followersModel*)) callback;

-(followersModel*) getFollowerByName:(NSString*) instagramId;
-(followersModel*) getNextFollower;
-(followersModel*) currentFollower;
-(void) loadFollowers;
-(void) removeAndFollowWithInstId:(NSString*) instagramId Id:(NSString* ) Id ;
-(void) logoutAction;
@end
