//
//  LevelManager.m
//  5000Followers
//
//  Created by Koctya on 12/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "LevelManager.h"
#import <Parse/Parse.h>
#import "Managers.h"

@implementation LevelManager
+ (LevelManager*) sharedManager {
    
    static LevelManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LevelManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.userLevel = -1;
    }
    return self;
}
-(void) logoutAction {
    self.userLevel = -1;
}
-(void) loadUserLevel {
    PFQuery* userLevel = [[PFQuery alloc] initWithClassName:USER_LEVEL_CLASS];
    [userLevel whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userLevel getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(error != nil) {
            if(object == nil) {
                PFObject* newUserLevel = [[PFObject alloc] initWithClassName:USER_LEVEL_CLASS];
                newUserLevel[USER_ID] = [PFUser currentUser];
                newUserLevel[LEVEL_FIELD] = @1;
                newUserLevel[REMAIN_FOLLOWERS_FIELD] = @100;
                [newUserLevel saveInBackground];
                self.userLevel = 1;
                self.userRemainFollowers = 100;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMAIN_CHANGE
                                                                    object:nil];
            }
        }else {
            self.userLevel =  (int)[object[LEVEL_FIELD] integerValue];
            self.userRemainFollowers = (int)[object[REMAIN_FOLLOWERS_FIELD] integerValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMAIN_CHANGE
                                                                object:nil];
        }
    }];
}

-(void) decreaseRemainFollowers {
    if(self.userRemainFollowers == 1) {
        PFQuery* userLevel = [[PFQuery alloc] initWithClassName:USER_LEVEL_CLASS];
        [userLevel whereKey:USER_ID equalTo:[PFUser currentUser]];
        [userLevel getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(error == nil) {
                object[LEVEL_FIELD] = @((int)[object[LEVEL_FIELD] integerValue] + 1);
                object[REMAIN_FOLLOWERS_FIELD] = @100;
                [object saveInBackground];
                self.userLevel++;
                self.userRemainFollowers = 100;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LEVEL_UP
                                                                    object:nil];
            }
        }];

    }else {
        PFQuery* userLevel = [[PFQuery alloc] initWithClassName:USER_LEVEL_CLASS];
        [userLevel whereKey:USER_ID equalTo:[PFUser currentUser]];
        [userLevel getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if(error == nil) {
                object[REMAIN_FOLLOWERS_FIELD] = @((int)[object[REMAIN_FOLLOWERS_FIELD] integerValue] - 1);
                [object saveInBackground];
                self.userRemainFollowers--;
            }
        }];
        
    }
    
}

@end
