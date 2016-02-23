 //
//  FollowersManager.m
//  5000Followers
//
//  Created by Koctya on 11/28/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "FollowersManager.h"
#import "Managers.h"
#import "followersModel.h"
#import <InstagramKit/InstagramKit.h>
#import "Helper.h"

@interface FollowersManager ()
@property int state;
@property int currentIndex;
@property int countUserFollowing;
@property int penaltyCount;
@property NSMutableArray* nFollowers;
@property BOOL nBlock;


@end

@implementation FollowersManager
+ (FollowersManager*) sharedManager {
    
    static FollowersManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FollowersManager alloc] init];
    });
    return manager;
}

- (id)init
{   
    self = [super init];
    if (self) {
        self.state = NOT_LOADED;
        self.currentIndex = -1;
        self.updateState = NOT_LOADED;
        self.followers = [[NSMutableArray alloc] init];
        self.userFollowings = [[NSMutableArray alloc] init];
        self.nFollowers = [[NSMutableArray alloc] init];
        self.nBlock = NO;
    }
    return self;
}

-(void) logoutAction {
    self.state = NOT_LOADED;
    self.currentIndex = -1;
    self.updateState = NOT_LOADED;
    self.followers = [[NSMutableArray alloc] init];
    self.userFollowings = [[NSMutableArray alloc] init];
}

-(void) loadFollowers {
    [self.userFollowings removeAllObjects];
    [self.followers removeAllObjects];
    self.state = NOT_LOADED;
    PFQuery* userFollowings = [[PFQuery alloc] initWithClassName:USER_FOLLOWINGS_CLASS];
    [userFollowings whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userFollowings findObjectsInBackgroundWithBlock:^(NSArray * _Nullable follows, NSError * _Nullable error) {
        for (PFObject* obj in follows) {
            [self.userFollowings addObject:obj[INSTAGRAM_ID_FIELD]];
        }
        PFQuery* searchCategory = [[PFQuery alloc] initWithClassName:USER_SEARCH_CATEGORIES_CLASS];
        [searchCategory whereKey:USER_ID equalTo:[PFUser currentUser]];
        PFQuery* ownCategory = [[PFQuery alloc] initWithClassName:USER_OWN_CATEGORIES_CLASS];
        [ownCategory whereKey:USER_ID notEqualTo:[PFUser currentUser]];
        [ownCategory whereKey:CATEGORIES_FIELD matchesKey:CATEGORIES_FIELD inQuery:searchCategory];
        PFQuery* followers = [[PFQuery alloc] initWithClassName:FOLLOWERS_CLASS];
        [followers whereKey:INSTAGRAM_ID_FIELD matchesKey:INSTAGRAM_ID_FIELD inQuery:ownCategory];
        [followers findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            for (PFObject* user in objects) {
                followersModel* follower = [[followersModel alloc] initWithObjectId:user.objectId instagramId:user[INSTAGRAM_ID_FIELD] followers:[user[FOLLOWERS_FIELD] integerValue] ];
                if(![self.userFollowings containsObject:follower.instagramId]) {
                   [self.followers addObject:follower]; 
                }
                
            }
            self.updateState = LOADED;
            self.state = LOADED;
            [self checkFollowerPenalty];
            
        }];
    }];
}


-(void) loadNewFollowersInBackground {
    self.nBlock = YES;
    [self.nFollowers removeAllObjects];
    PFQuery* userFollowings = [[PFQuery alloc] initWithClassName:USER_FOLLOWINGS_CLASS];
    [userFollowings whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userFollowings findObjectsInBackgroundWithBlock:^(NSArray * _Nullable follows, NSError * _Nullable error) {
        for (PFObject* obj in follows) {
            if([self.userFollowings containsObject:obj[INSTAGRAM_ID_FIELD]] == NO) {
                [self.userFollowings addObject:obj[INSTAGRAM_ID_FIELD]];
            }
        }
        PFQuery* searchCategory = [[PFQuery alloc] initWithClassName:USER_SEARCH_CATEGORIES_CLASS];
        [searchCategory whereKey:USER_ID equalTo:[PFUser currentUser]];
        PFQuery* ownCategory = [[PFQuery alloc] initWithClassName:USER_OWN_CATEGORIES_CLASS];
        [ownCategory whereKey:USER_ID notEqualTo:[PFUser currentUser]];
        [ownCategory whereKey:CATEGORIES_FIELD matchesKey:CATEGORIES_FIELD inQuery:searchCategory];
        PFQuery* followers = [[PFQuery alloc] initWithClassName:FOLLOWERS_CLASS];
        [followers whereKey:INSTAGRAM_ID_FIELD matchesKey:INSTAGRAM_ID_FIELD inQuery:ownCategory];
        [followers findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            for (PFObject* user in objects) {
                BOOL flag = NO;
                for (followersModel* item in self.followers) {
                    if([item.instagramId isEqualToString:user[INSTAGRAM_ID_FIELD]]) {
                        flag = YES;
                        break;
                    }
                }
                if(flag == YES) {
                    continue;
                }
                followersModel* follower = [[followersModel alloc] initWithObjectId:user.objectId instagramId:user[INSTAGRAM_ID_FIELD] followers:[user[FOLLOWERS_FIELD] integerValue] ];
                if(![self.userFollowings containsObject:follower.instagramId]) {
                    [self.followers addObject:follower];
                }
                
            }
            self.nBlock = NO;
            
        }];
    }];
    
    
}

-(void) endChecking {
    self.countUserFollowing--;
    if(self.countUserFollowing == 0) {
        if(self.penaltyCount != 0) {
            [[UserManager sharedManager] decreaseUserCoins:self.penaltyCount onSuccess:^{
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleCancel handler:nil];
                UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                [Helper showAlertViewWithContext:vc title:str_Penalty_message message:[NSString stringWithFormat:str_PFU,self.penaltyCount] style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
            } onFailure:^(NSError * error) {
                
            }];

        }else {
        }
    }
}

-(void) checkFollowerPenalty {
    self.countUserFollowing = (int)[self.userFollowings count];
    self.penaltyCount = 0;
    for (NSString* item in self.userFollowings) {
        InstagramEngine *engine = [InstagramEngine sharedEngine];
        [engine searchUsersWithString:item withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
            for (InstagramUser* user in users) {
                if([user.username isEqualToString:item]) {
                    [engine getRelationshipStatusOfUser:user.Id withSuccess:^(NSDictionary *serverResponse) {
                        if([serverResponse[@"outgoing_status"]  isEqual: @"none"]) {
                            [self removeFollowerByInstagramId:item];
                            self.penaltyCount += 10;
                        }
                        [self endChecking];
                    } failure:^(NSError *error, NSInteger serverStatusCode) {
                        [self endChecking];
                    }];
                }
            }

        } failure:^(NSError *error, NSInteger serverStatusCode) {
            
        }];
    }
}

-(void) removeFollowerByInstagramId:(NSString*) instagramId {
    PFQuery* userFollowings = [[PFQuery alloc] initWithClassName:USER_FOLLOWINGS_CLASS];
    [userFollowings whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userFollowings findObjectsInBackgroundWithBlock:^(NSArray * _Nullable follows, NSError * _Nullable error) {
        for (PFObject* obj in follows) {
            if([obj[INSTAGRAM_ID_FIELD] isEqualToString:instagramId]) {
                [obj deleteInBackground];
            }
        }
    }];
}
-(void) getFollowersonSuccess: (void(^) (NSMutableArray* )) success {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self checkState];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            success(self.followers);
        });
    });
}

-(followersModel*) getNextFollower {
    [self checkState];
    self.currentIndex++;
    if(self.currentIndex >= self.followers.count ) {
        if([self checkAndLoadNewFollowers]) {
            
        }else {
            self.currentIndex = 0;
        }
    }
   [self loadAndCasheNextUsers];
    return (followersModel*)self.followers[self.currentIndex];
}

-(followersModel*) currentFollower {
    if(self.currentIndex >= self.followers.count ) {
        if([self checkAndLoadNewFollowers]) {
            
        }else {
            self.currentIndex = 0;
        }
    }
    self.updateState = NOT_LOADED;
    [self loadAndCasheNextUsers];
    return (followersModel*)self.followers[self.currentIndex];
}

-(void) loadAndCasheNextUsers {
    if(self.currentIndex +  2 < self.followers.count ) {
        [self getFollowerDetails:self.followers[self.currentIndex + 1] withCallback:^(followersModel * lol) {
        }];
        [self getFollowerDetails:self.followers[self.currentIndex + 2] withCallback:^(followersModel * lol) {
        }];
    }else if(self.currentIndex +  1 < self.followers.count ) {
        [self getFollowerDetails:self.followers[self.currentIndex + 1] withCallback:^(followersModel * lol) {
        }];
    }else{
        if(self.nBlock == NO) {
           [self loadNewFollowersInBackground];
        }
        
        return;
    }
}

-(void) removeAndFollowWithInstId:(NSString*) instagramId Id:(NSString* ) Id {
    for (int i = 0; i < self.followers.count; i++) {
        if([((followersModel*)self.followers[i]).instagramId isEqual:instagramId]) {
            InstagramEngine *engine = [InstagramEngine sharedEngine];
            [engine followUser:Id withSuccess:^(NSDictionary *serverResponse) {
            } failure:^(NSError *error, NSInteger serverStatusCode) {
            }];
            [self.followers removeObjectAtIndex:i];
            [self.userFollowings addObject:instagramId];
            break;
        }
    }
}

-(BOOL) checkAndLoadNewFollowers {
    return NO;
}

-(void) checkState {
    while (self.state != LOADED) {
        
    }
}

-(void) getFollowerDetails:(followersModel*) detailUser withCallback: (void(^) (followersModel*)) callback {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    __block int parts = 2;
    if(detailUser.userPhoto != nil && [detailUser.userMedia count] != 0 &&detailUser.followingCount != -1 && detailUser.followerCount != -1 ) {
        return callback(detailUser);
    }else {
        [engine searchUsersWithString:detailUser.instagramId withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
            for (InstagramUser* user in users) {
                if([user.username isEqualToString:detailUser.instagramId]) {
                    detailUser.userPhoto = ((InstagramUser*)users[0]).profilePictureURL;
                    
                    if([((InstagramUser*)users[0]).fullName  isEqual: @""]) {
                        detailUser.userName = ((InstagramUser*)users[0]).username;
                    }else {
                        detailUser.userName = ((InstagramUser*)users[0]).fullName;
                    }
                    
                    [engine getUserDetails:((InstagramUser*)users[0]).Id withSuccess:^(InstagramUser *user) {
                        detailUser.followerCount = (int)user.followedByCount;
                        detailUser.followingCount = (int)user.followsCount;
                        parts-- ;
                        if(parts == 0) {
                            callback(detailUser);
                        }
                    } failure:^(NSError *error, NSInteger serverStatusCode) {
                        detailUser.followerCount = 0;
                        detailUser.followingCount = 0;
                        parts-- ;
                        if(parts == 0) {
                            callback(detailUser);
                        }
                    }];
                    [engine getMediaForUser:((InstagramUser*)users[0]).Id count:4 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                        if(media.count < 4) {
                            [detailUser.userMedia removeAllObjects];
                            return;
                        }
                        for (InstagramMedia* item in media) {
                            [detailUser.userMedia addObject:item.lowResolutionImageURL];
                        }
                        parts-- ;
                        if(parts == 0) {
                            callback(detailUser);
                        }
                    } failure:^(NSError *error, NSInteger serverStatusCode) {
                        parts-- ;
                        if(parts == 0) {
                            callback(detailUser);
                        }
                    }];
                    return;
                }
            }
        } failure:^(NSError *error, NSInteger serverStatusCode) {
            
        }];
        

    }
}


-(followersModel*) getFollowerByName:(NSString*) instagramId {
    [self checkState];
    for (followersModel* itm in self.followers) {
        if([itm.instagramId isEqualToString:instagramId ]) {
            return itm;
        }
    }
    return nil;
}

-(void) addUserToFollowersWithId:(NSString*) instagram_id countFollowers:(NSInteger) countFollowers onSuccess: (void(^) ()) success onFailure:(void(^) (NSError*)) failure {
    PFQuery* followerExist = [[PFQuery alloc] initWithClassName:FOLLOWERS_CLASS];
    [followerExist whereKey:USER_ID equalTo:[PFUser currentUser]];
    [followerExist getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object != nil) {
            [UserManager sharedManager].followersLeft = (int)([object[FOLLOWERS_FIELD] integerValue] + countFollowers);
            [UserManager sharedManager].followersMaxCount = (int)([object[FOLLOWERS_MAX_FIELD] integerValue] + countFollowers);
            object[FOLLOWERS_FIELD] = @((int)[object[FOLLOWERS_FIELD] integerValue] + countFollowers);
            object[FOLLOWERS_MAX_FIELD] = @((int)[object[FOLLOWERS_MAX_FIELD] integerValue] + countFollowers);
            [object saveInBackground];
            if(success) {
                
                success();
                return;
            }
        }else {
            PFObject* newFollowerUser = [[PFObject alloc] initWithClassName:FOLLOWERS_CLASS];
            newFollowerUser[USER_ID ] = [PFUser currentUser];
            newFollowerUser[FOLLOWERS_FIELD] = @(countFollowers);
            newFollowerUser[INSTAGRAM_ID_FIELD] = [PFUser currentUser][INSTAGRAM_ID_FIELD];
            [UserManager sharedManager].followersLeft = (int)countFollowers;
            [UserManager sharedManager].followersMaxCount = (int)countFollowers;
            newFollowerUser[FOLLOWERS_MAX_FIELD] = @(countFollowers);
            [newFollowerUser saveInBackground];
            if(success) {
                success();
                return;
            }
        }
    }];
}

@end
