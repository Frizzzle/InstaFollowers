//
//  UserManager.m
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/20/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "UserManager.h"
#import <InstagramKit.h>
#import "Managers.h"


@interface UserManager ()
@property int rateValue;
@end

@implementation UserManager
@synthesize rateValue;

+ (UserManager*) sharedManager {
    
    static UserManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self checkRateClass];

    }
    
    return self;
}

-(void) checkRateClass {
    PFQuery* checkQuery = [[PFQuery alloc] initWithClassName:LOCAL_RATE_CLASS];
    [checkQuery fromLocalDatastore];
    [checkQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if([objects count] == 0) {
            PFObject* rateObject = [[PFObject alloc] initWithClassName:LOCAL_RATE_CLASS];
            rateObject[LOCAL_RATE_REMIND_FIELD ] = @NO;
            rateObject[LOCAL_RATE_AVAILABILITY_FIELD] = @YES;
            rateObject[LOCAL_RATE_COUNT_FIELD] = @1;
            [rateObject pinInBackground];
        }else {
            PFObject* obj = objects[0];
            if([obj[LOCAL_RATE_AVAILABILITY_FIELD] boolValue] == YES && [obj[LOCAL_RATE_COUNT_FIELD] integerValue] >= 10 ) {
                if([obj[LOCAL_RATE_REMIND_FIELD] boolValue] == YES) {
                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                    NSDate* remindDate = [obj updatedAt];
                    NSTimeInterval interval = [remindDate timeIntervalSinceDate:[NSDate date]];
                    int delta = (TIME_SEC_IN_DAY) + interval;
                    if(delta <= 0) {
                        [self checkReteAvailable];
                        obj[LOCAL_RATE_REMIND_FIELD ] = @NO;
                        obj[LOCAL_RATE_AVAILABILITY_FIELD] = @YES;
                        [obj pinInBackground];
                    }
                }else {
                    [self checkReteAvailable];
                }
            }else {
                obj[LOCAL_RATE_COUNT_FIELD] = @([obj[LOCAL_RATE_COUNT_FIELD] integerValue] + 1) ;
                [obj pinInBackground];
            }
        }
    }];
}

-(void) updateFollowersLeftOnFinish:(void(^) ()) finish  {
    PFQuery* getUserFollowersCount = [[PFQuery alloc] initWithClassName:FOLLOWERS_CLASS];
    [getUserFollowersCount whereKey:USER_ID equalTo:[PFUser currentUser]];
    [getUserFollowersCount getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSInteger countFollowers = [object[FOLLOWERS_FIELD] integerValue];
        NSInteger maxCount = [object[FOLLOWERS_MAX_FIELD] integerValue];
        if((countFollowers != self.followersLeft) || (maxCount != self.followersMaxCount)) {
            self.followersLeft = (int)countFollowers;
            self.followersMaxCount = (int)maxCount;
            finish();
        }
    }];
}

-(void) enablePowerFollow {
    self.isPowerFollowEnabled = YES;
    PFQuery* getPowerQuery = [[PFQuery alloc] initWithClassName:USER_COINS_CLASS];
    [getPowerQuery whereKey:USER_ID equalTo:[PFUser currentUser]];
    [getPowerQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        object[POWER_FOLLOW_FIELD] = @YES;
        self.isPowerFollowEnabled = YES;
        [object saveInBackground];
    }];
}

-(void) getUserInfo {
    PFQuery* getUserCoinsQuery = [[PFQuery alloc] initWithClassName:USER_COINS_CLASS];
    [getUserCoinsQuery whereKey:USER_ID equalTo:[PFUser currentUser]];
    [getUserCoinsQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSInteger countCoins = [object[COINS_FIELD] integerValue];
        self.userCoins = (int)countCoins;
        [[TapJoyManager sharedManager] synchronizeCoinsOnTapJoy];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_COINS
                                                            object:nil];
    }];
    PFQuery* getUserFollowersCount = [[PFQuery alloc] initWithClassName:FOLLOWERS_CLASS];
    [getUserFollowersCount whereKey:USER_ID equalTo:[PFUser currentUser]];
    [getUserFollowersCount getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSInteger countFollowers = [object[FOLLOWERS_FIELD] integerValue];
        self.followersLeft = (int)countFollowers;
        NSInteger maxCount = [object[FOLLOWERS_MAX_FIELD] integerValue];
        self.followersMaxCount = (int)maxCount;
    }];
    PFQuery* getPowerQuery = [[PFQuery alloc] initWithClassName:USER_COINS_CLASS];
    [getPowerQuery whereKey:USER_ID equalTo:[PFUser currentUser]];
    [getPowerQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        _Bool enabled = [object[POWER_FOLLOW_FIELD] boolValue];
        self.isPowerFollowEnabled = enabled;
    }];
    
}

-(void) makeFollowToUser:(NSString*) instagramId Id:(NSString* ) Id onSuccess:(void(^) ()) success onFailure:(void(^) (NSError*)) failure {
    [[FollowersManager sharedManager] removeAndFollowWithInstId:instagramId Id:Id];
    PFObject* newFollower = [[PFObject alloc] initWithClassName:USER_FOLLOWINGS_CLASS];
    newFollower[USER_ID] = [PFUser currentUser];
    newFollower[INSTAGRAM_ID_FIELD] = instagramId;
    [newFollower saveInBackground];
    PFQuery* decreaseUserFollowing = [[PFQuery alloc] initWithClassName:FOLLOWERS_CLASS];
    [decreaseUserFollowing whereKey:INSTAGRAM_ID_FIELD equalTo:instagramId];
    [decreaseUserFollowing getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(((int)[object[FOLLOWERS_FIELD] integerValue]) <= 1) {
            [object deleteInBackground];
            return;
        }
        object[FOLLOWERS_FIELD] = @((int)[object[FOLLOWERS_FIELD] integerValue] - 1);
        [object saveInBackground];
    }];
    success();
}

-(void) setUserOnSuccess:(void(^)(bool state)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    [engine getSelfUserDetailsWithSuccess:^(InstagramUser *userInstagram) {
        
        PFQuery *query = [PFUser query];
        [query whereKey:INSTAGRAM_ID_FIELD equalTo:userInstagram.username];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object != nil) {
                [PFUser logInWithUsernameInBackground:userInstagram.username password:DEFAULT_USER_PASS
                                                block:^(PFUser *user, NSError *error) {
                                                    if (user) {
                                                        if(success) {
                                                            success(YES);
                                                            
                                                            [[FollowersManager sharedManager] loadFollowers];
                                                            [[LevelManager sharedManager] loadUserLevel] ;
                                                            
                                                            [CategoryManager sharedManager];
                                                            [[BonusManager sharedManager] loadRewards];
      
                                                            [[Branch getInstance] setIdentity:[PFUser currentUser][INSTAGRAM_ID_FIELD]];
                                                            
                                                            [self getUserInfo];
                                                            return;
                                                        }
                                                    } else {
                                                        if(failure) {
                                                            failure(error, [error code]);
                                                            return;
                                                        }
                                                    }
                                                }];
                
            }
            else
            {
                PFUser *user = [PFUser user];
                user.username = userInstagram.username;
                [user setObject:userInstagram.username forKey:INSTAGRAM_ID_FIELD];
                user.password = DEFAULT_USER_PASS;

                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [[FollowersManager sharedManager] loadFollowers];
                        [CategoryManager sharedManager];
                        [[LevelManager sharedManager] loadUserLevel];
                        [[BonusManager sharedManager] loadRewards];
                        [[Branch getInstance] setIdentity:[PFUser currentUser][INSTAGRAM_ID_FIELD]];
                        PFObject *coins = [PFObject objectWithClassName:USER_COINS_CLASS];
                        coins[USER_ID] = [PFUser currentUser];
                        coins[COINS_FIELD] = [NSNumber numberWithInt:150];
                        coins[POWER_FOLLOW_FIELD] = @NO;
                        self.userCoins = 150;
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_UPDATE_COINS
                                                                            object:nil];
                        [coins saveInBackground]; 
                        if(success) {
                            success(YES);
                            
                            
                            return;
                        }
                        
                    } else {
                        if(failure) {
                            failure(error, [error code]);
                            return;
                        }
                        
                    }
                }];
            }
        }];
    } failure:^(NSError *error, NSInteger serverStatusCode) {
        if(failure) {
            failure(error, [error code]);
            return;
        }
    }];
}

-(void) increaseUserCoins:(NSInteger) cointsCount onSuccess:(void(^) ()) success onFailure:(void(^) (NSError*)) failure {
    PFQuery* userCoins = [[PFQuery alloc] initWithClassName:USER_COINS_CLASS];
    [userCoins whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userCoins getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object != nil){
            object[COINS_FIELD] = @((int)[object[COINS_FIELD] integerValue] + cointsCount);
            self.userCoins = self.userCoins + (int)cointsCount;
            
            [object saveInBackground];
            success();
            return;
        }
    }];
}

-(void) decreaseUserCoins:(NSInteger) cointsCount onSuccess:(void(^) ()) success onFailure:(void(^) (NSError*)) failure {
    PFQuery* userCoins = [[PFQuery alloc] initWithClassName:USER_COINS_CLASS];
    [userCoins whereKey:USER_ID equalTo:[PFUser currentUser]];
    [userCoins getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object != nil){
            if(@((int)[object[COINS_FIELD] integerValue] - cointsCount) < 0) {
                failure([[NSError alloc] initWithDomain:@"Wrong count user coins" code:400 userInfo:nil]);
                return;
            }
            object[COINS_FIELD] = @((int)[object[COINS_FIELD] integerValue] - cointsCount);
            self.userCoins = self.userCoins - (int)cointsCount;
            
            [object saveInBackground];
            success();
            return;
        }
    }];
}

-(void) accountIsSetupWithUserId:(PFUser*) userId isSet:(void(^) ()) isSet isNotSet:(void(^) ()) isNotSet {
    [[CategoryManager sharedManager] getOwnCategoriesOnLoad:^(NSMutableArray *ownCategory) {
        if([ownCategory count] == 0) {
            isNotSet();
        }else {
            [[CategoryManager sharedManager] getSearchCategoriesOnLoad:^(NSMutableArray *searchCategory) {
                if([searchCategory count] == 0) {
                    isNotSet();
                }else {
                    isSet();
                }
            }];
        }
    }];
}
-(void) checkReteAvailable {
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath]; // e.g. /var/mobile/Applications/<GUID>/<AppName>.app
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary* attrs = [manager attributesOfItemAtPath:bundleRoot error:nil];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate* adte = attrs[@"NSFileCreationDate"];
    NSTimeInterval interval = [adte timeIntervalSinceDate:[NSDate date]];
    int delta = (TIME_SEC_IN_DAY * 5) + interval;
    if(delta < 0) {
        [self makeRateAlert];
    }
    
    
}
-(void) makeRateAlert {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    [alertView setContainerView:[self createAlertView]];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:str_Rate,str_Remind,str_Cancel,nil]];
    [alertView setDelegate:self];

    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    PFObject* rate = [[PFObject alloc] initWithClassName:USER_RAITING_CLASS];
    PFQuery* rateReq = [[PFQuery alloc] initWithClassName:LOCAL_RATE_CLASS];
    [rateReq fromLocalDatastore];
    [rateReq getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        switch (buttonIndex) {
            case 0:
                object[LOCAL_RATE_AVAILABILITY_FIELD] = @NO;
                [object pinInBackground];
                rate[USER_ID] = [PFUser currentUser];
                rate[RAITING_FIELD] = @(self.rateValue);
                [rate saveInBackground];
                break;
            case 1:
                object[LOCAL_RATE_AVAILABILITY_FIELD] = @YES;
                object[LOCAL_RATE_REMIND_FIELD] = @YES;
                object[LOCAL_RATE_REMIND_DATE_FIELD] = [NSDate date];
                [object pinInBackground];
                break;
            case 2:
                object[LOCAL_RATE_AVAILABILITY_FIELD] = @NO;
                [object pinInBackground];
                break;
                
            default:
                break;
        }
        
    }];
    [alertView close];
}

-(UIView*) createAlertView {
    UIView* levelUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270 , 210)];
    [levelUpView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(5 , 5, 260, 30)];
    title.text = str_RIF;
    title.font = [UIFont systemFontOfSize:17];
    
    title.textAlignment = NSTextAlignmentCenter;
    [levelUpView addSubview:title];
    
    UIImageView* line1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 270, 1)];
    [line1 setTintColor:[UIColor whiteColor]];
    [levelUpView addSubview:line1];
    
    UILabel* message = [[UILabel alloc] initWithFrame:CGRectMake(5 , 46, 260, 104)];
    message.text = str_RT;
    message.font = [UIFont systemFontOfSize:17];
    message.numberOfLines = 15;
    
    message.textAlignment = NSTextAlignmentCenter;
    [levelUpView addSubview:message];
    UIView* buttonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 270 , 60)];
    NSMutableArray* otherButtons = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 5; i++) {
        DLRadioButton *radioButton = [[DLRadioButton alloc] initWithFrame:CGRectMake(40 * i, 15, 30 , 30)];
        radioButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [radioButton setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [radioButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        radioButton.iconColor = [UIColor blueColor] ;
        radioButton.indicatorColor = [UIColor blueColor] ;
        radioButton.iconSquare = NO;
        radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        
        [radioButton addTarget:self action:@selector(changeRateValue:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsView addSubview:radioButton];
        if(i != 5) {
            [otherButtons addObject:radioButton];
            
        }else {
            radioButton.otherButtons = otherButtons;
            [radioButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
    [levelUpView addSubview:buttonsView];
    
    
    
    return levelUpView;
}

-(void)changeRateValue:(DLRadioButton *)radiobutton {
    self.rateValue = [radiobutton.selectedButton.titleLabel.text intValue];
}


@end
