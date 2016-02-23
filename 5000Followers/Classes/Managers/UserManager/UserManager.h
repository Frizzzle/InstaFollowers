//
//  UserManager.h
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/20/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <PFQuery.h>
#import <DLRadioButton/DLRadioButton.h>
#import <CustomIOSAlertView/CustomIOSAlertView.h>
#import <MessageUI/MessageUI.h>
#import <Branch/BranchUniversalObject.h>

@interface UserManager : NSObject<CustomIOSAlertViewDelegate,MFMailComposeViewControllerDelegate>

+ (UserManager *) sharedManager;

@property int userCoins;
@property int followersLeft;
@property int followersMaxCount;
@property BOOL isPowerFollowEnabled;


-(void) updateFollowersLeftOnFinish:(void(^) ()) finish;

-(void) setUserOnSuccess:(void(^)(bool state)) success onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) decreaseUserCoins:(NSInteger) cointsCount onSuccess:(void(^) ()) success onFailure:(void(^) (NSError*)) failure;

-(void) getCategoryListOnSuccess:(void(^) (NSArray*)) success onFailure:(void(^) (NSError* error)) failure;

-(void) getUserOwnCategoriesWithUser:(PFUser*) userId OnSuccess:(void(^) (NSArray*)) success onFailure:(void(^) (NSError* error)) failure;


-(void) accountIsSetupWithUserId:(PFUser*) userId isSet:(void(^) ()) isSet isNotSet:(void(^) ()) isNotSet;

-(void) makeFollowToUser:(NSString*) instagramId Id:(NSString* ) Id onSuccess:(void(^) ()) success onFailure:(void(^) (NSError*)) failure;

-(void) increaseUserCoins:(NSInteger) cointsCount onSuccess:(void(^) ()) success onFailure:(void(^) (NSError*)) failure;

-(void) enablePowerFollow;


@end
