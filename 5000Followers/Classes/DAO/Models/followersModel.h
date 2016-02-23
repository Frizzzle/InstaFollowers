//
//  followersModel.h
//  5000Followers
//
//  Created by Koctya on 12/8/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface followersModel : NSObject
@property  NSString* objectId;
@property  NSString* instagramId;
@property  NSInteger followers;
@property  NSURL* userPhoto;
@property  NSMutableArray* userMedia;
@property  int followerCount;
@property  int followingCount;
@property  NSString* userName;

- (id)initWithObjectId:(NSString*) objectId instagramId:(NSString*) instagramId
             followers:(NSInteger) followers;
- (void) addUserMediaUrls:(NSMutableArray*) urls;
@end
