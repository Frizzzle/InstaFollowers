//
//  followersModel.m
//  5000Followers
//
//  Created by Koctya on 12/8/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "followersModel.h"

@implementation followersModel
- (id) init {
    self = [super init];
    if(self){
        self.objectId = nil;
        self.instagramId = nil;
        self.followers = 0;
        self.userPhoto = nil;
        self.userMedia = [[NSMutableArray alloc] init];
        self.followerCount = -1;
        self.followingCount = -1;
    }
    return self;
}

- (id)initWithObjectId:(NSString*) objectId instagramId:(NSString*) instagramId  followers:(NSInteger) followers {
    self = [self init];
    self.objectId = objectId;
    self.instagramId = instagramId;
    self.followers = followers;
    return self;
}
- (void) addUserMediaUrls:(NSMutableArray*) urls{
    self.userMedia = [[NSMutableArray alloc] initWithArray:urls];
}

@end
