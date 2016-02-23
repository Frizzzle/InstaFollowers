//
//  Constants.h
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/18/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#pragma mark SEGUE
#define SEGUE_MAIN                                      @"showMain"
#define SEGUE_LOGIN                                     @"showLogin"
#define SEGUE_SETUP                                     @"showSetup"
#define SEGUE_ACCOUNT                                   @"showAccount"
#define SEGUE_SET_CATEGORIES                            @"showSetCategories"

#pragma mark STRINGS FOR LOCALIZATION

#define OK_BTN                                          NSLocalizedString(@"OK", nil)
#define OK_RETRY                                        NSLocalizedString(@"Retry", nil)
#define LOGIN_TITLE                                     NSLocalizedString(@"LOGIN IN TO INSTAGRAM", nil)
#define MAIN_TITLE                                      NSLocalizedString(@"Get Coins", nil)

#pragma mark KEYS

#define PARSE_APP_ID                                    @"b8XXilZp3jC4hPbuBYaJSSqs3QW0Qwaa2v0lngDe"
#define PARSE_CLIENT_KEY                                @"VlFLVAeMV0oPicyV78DOUN0mTM1evohW4onENKc3"
#define TWITTER_CONSUMER_KEY                            @"a4CX4URyk717964E0NKgoHxnt"
#define TWITTER_CONSUMER_SECRET_KEY                     @"voXreu3MhVSnejLs67Uclj8GG6HTGCcWptHCkX4NGDQ16EIclH"
#define TAPJOY_CONNECT_KEY                              @"2la7XgyrTW-JmzKwOOKHJQEB7T0RIIl1qoXxQVmxG74adN1v0gq_eVEXGXJp"
#pragma mark PARSE



#pragma mark PASS
#define DEFAULT_USER_PASS                               @"FollowPassord"

#pragma mark PARSE_CONSTANTS


#define BUY_COINS_CLASS                                 @"BuyCoins"
#define USER_COINS_CLASS                                @"UserCoins"
#define BUY_FOLLOWERS_CLASS                             @"BuyFollowers"
#define FOLLOWERS_CLASS                                 @"Followers"
#define CATEGORIES_CLASS                                @"Categories"

#define CATEGORIES_LOCAL_CLASS                          @"LocalsCategories"
#define LOCAL_OWN_CATEGORIES_CLASS                      @"LocalsOwnCategories"
#define LOCAL_SEARCH_CATEGORIES_CLASS                   @"LocalsSearchCategories"
#define LOCAL_RATE_CLASS                                @"LocalsRate"


#define USER_RAITING_CLASS                              @"UserRaiting"
#define USER_OWN_CATEGORIES_CLASS                       @"UserOwnCategories"
#define USER_SEARCH_CATEGORIES_CLASS                    @"UserSearchCategories"
#define USER_FOLLOWINGS_CLASS                           @"UserFollowings"
#define USER_LEVEL_CLASS                                @"UserLevel"
#define LEVEL_REWARD_CLASS                              @"LevelReward"
#define USER_LEVEL_REWARDS_CLASS                        @"UserLevelRewards"

#define LOCAL_RATE_AVAILABILITY_FIELD                   @"RateAvailability"
#define LOCAL_RATE_REMIND_FIELD                         @"RateRemind"
#define LOCAL_RATE_REMIND_DATE_FIELD                    @"RateRemindRate"
#define LOCAL_RATE_COUNT_FIELD                          @"RateCount"

#define RAITING_FIELD                                   @"raiting"
#define CATEGORIES_FIELD                                @"categoryId"
#define CATEGORIES_NAME_FIELD                           @"categoryName"
#define COINS_FIELD                                     @"coins"
#define POWER_FOLLOW_FIELD                              @"isPowerFollowEnabled"
#define USER_ID                                         @"userId"
#define BONUS_FIELD                                     @"bonus"
#define IS_BONUS_ENABLE_FIELD                           @"isBonusEnabled"
#define IS_MOST_POPULAR_FIELD                           @"isMostPopular"
#define IS_BEST_VALUE_FIELD                             @"isBestValue"
#define INAPP_ID                                        @"inapp_id"
#define FOLLOWERS_FIELD                                 @"followers"
#define FOLLOWERS_MAX_FIELD                             @"followersMax"
#define INSTAGRAM_ID_FIELD                              @"instagram_id"
#define REMAIN_FOLLOWERS_FIELD                          @"remainFollowers"
#define LEVEL_FIELD                                     @"level"
#define REQUIRED_LEVEL_FIELD                            @"requiredLevel"
#define REWARD_FIELD                                    @"reward"
#define REWARD_ID_FIELD                                 @"rewardId"

#define TIME_SEC_IN_DAY                                 86400
#pragma mark COLORS 

#define NAVBAR_COLOR                                    [UIColor colorWithRed:78.0/255.0 green:112.0/255.0 blue:192.0/255.0 alpha:1.0]
#define BUTTON_ALPHA                                    [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.0]
#define BUTTON_BLUE                                     [UIColor colorWithRed:71.0/255.0 green:101.0/255.0 blue:183.0/255.0 alpha:1.0]
#define BUTTON_GREEN                                    [UIColor colorWithRed:19.0/255.0 green:130.0/255.0 blue:70.0/255.0 alpha:1.0]
#define BUTTON_PINK                                     [UIColor colorWithRed:90.0/255.0 green:50.0/255.0 blue:130.0/255.0 alpha:1.0]
#define BUTTON_BLUE_TWITTER                             [UIColor colorWithRed:7.0/255.0 green:120.0/255.0 blue:180.0/255.0 alpha:1.0]
#define BUTTON_BLUE_FACEBOOK                            [UIColor colorWithRed:50.0/255.0 green:80.0/255.0 blue:140.0/255.0 alpha:1.0]


#pragma mark STATES

#define NOT_LOADED                                      0
#define LOADED                                          1
#define ONE_LOAD                                        2
#define LOGOUT_LOAD                                     3

#pragma mark TYPES

#define TYPE_MAIN_CATEGORY                              0
#define TYPE_OWN_CATEGORY                               1
#define TYPE_SEARCH_CATEGORY                            2

#pragma mark TABBAR_INDEXES 

#define TAB_EARN_COINS                                  0
#define TAB_GET_FOLLOWERS                               1
#define TAB_BUY_COINS                                   2
#define TAB_BONUS_COINS                                 3

#pragma mark IMAGES_NAME

#define ICON_EARN_COINS                                 @"earn_coins_icon"
#define ICON_GET_FOLLOWERS                              @"get_followers_icon"
#define ICON_BUY_COINS                                  @"buy_coins_icon"
#define ICON_BONUS_COINS                                @"bonus_coins_icon"
#define ICON_MOST_POPULAR                               @"most_popular_icon"
#define ICON_BEST_VALUE                                 @"best_value_icon"


#pragma mark NOTIFICATIONS

#define NOTIF_UPDATE_COINS                              @"UpdateCoinsNotificationKey"
#define NOTIF_LOGOUT_ACTION                             @"LogoutNotification"
#define NOTIF_REMAIN_CHANGE                             @"FollowersRemainChange"
#define NOTIF_LEVEL_UP                                  @"LevelUp"


#pragma mark MORE_CONST             

#define MORE_COUNT_ROWS                                 5
#define MORE_EDIT_CATEGORIES_ROW                        0
#define MORE_CONTACT_US_ROW                             1
#define MORE_SHARE_ROW                                  2
#define MORE_HELP_ROW                                   3
#define MORE_LOG_OUT_ROW                                4

#define MORE_EDIT_CATEGORIES_NAME                       @"Edit Categories"
#define MORE_CONTACT_US_NAME                            @"Contact Us"
#define MORE_SHARE_NAME                                 @"Share"
#define MORE_HELP_NAME                                  @"Help"
#define MORE_LOGOUT_NAME                                @"Logout"

#pragma mark STRINGS

#define str_OK                                          @"OK"
#define str_Cancel                                      @"Cancel"
#define str_Failure                                     @"Failure"
#define str_Error                                       @"Error"

#define str_Disabled                                    @"Disabled"

#define str_Purchase_failure                            @"Purchase failure"
#define str_Purchase_successful                         @"Purchase successful"

#define str_account                                     @"account"
#define str_coins_icon                                  @"coins_icon"

#define str_Coins_Awarded                               @"Coins Awarded"
#define str_YHBAC                                       @"Your have been awarded %@ coins."
#define str_LDR                                         @"Level %ld: Daily reward"
#define str_TTCR                                        @"Tap to Claim Reward"
#define str_Low_Level                                   @"Low level"
#define str_no_price                                    @"no price"
#define str_FreeCoins                                   @"FreeCoins"

#define str_PFa                                         @"Power Follow activated"
#define str_Activated                                   @"Activated"
#define str_Power_Follow                                @"Power Follow"
#define str_Buy2                                        @"Buy %d + %d"
#define str_Buy                                     @"Buy %d"
#define str_For                                    @"For %d"
#define str_Done                                     @"Done"
#define str_All_Topics                                    @"All Topics"
#define str_Wrong_category                                     @"Wrong category"
#define str_PCC                                         @"Please choose category"
#define str_Penalty_message                                     @"Penalty message"
#define str_PFU                                     @"Penalty for unfollow - %d"
#define str_Buy_coins                                    @"Buy coins"
#define str_Cancel                                     @"Cancel"
#define str_NEC                                    @"Not enough coins"
#define str_Order_Complete                                     @"Order Complete"
#define str_YOIC                                     @"Your order is complete"

#define str_No                                     @"No"
#define str_Get_Followers                                    @"Get Followers"
#define str_AYSUWTGF                                     @"Are you sure you want to get %ld followers?"
#define str_background                                     @"background"
#define str_Help                                     @"Help"
#define str_Version                                     @"Version: <%@ build: %@>"
#define str_FR                                     @"%ld Followers Remain"
#define str_Level                                    @"Level %ld"
#define str_Follow                                     @"Follow +5"
#define str_icon_cross                                    @"icon_cross"
#define str_Skip                                     @"Skip"
#define str_Video5                                     @"Video + 5"
#define str_RFRU                                     @"Reward for referred users."
#define str_blue_bonus                                     @"blue_bonus"
#define str_Level_Up                                    @"Level Up"
#define str_100_Coins_Awarded                                     @"100 Coins Awarded"
#define str_Video                                    @"Video"
#define str_NVideo                                   @"No video."
#define str_FF                                     @"Followers v.%@ Feedback "
#define str_FRI                                     @"Followers v.%@ on %@ running iOS %@ "
#define str_LogOUT                                     @"You sure you want to Logout"
#define str_Loading                                     @"Loading"
#define str_UCategory                                     @"Updating categories"
#define str_ShareE                                     @"Share by Email"
#define str_CTC                                     @"Copy to Clipboard"
#define str_SBT                                    @"Share by Twitter"
#define str_SBF                                    @"Share by Facebook"
#define str_Rate                                    @"Rate"
#define str_Remind                                    @"Remind Later"
#define str_RIF                                    @"Rate Insta Followers"
#define str_RT                                     @"If you enjoy Insta Followers, Would you mind taking a moment to rate it? It won’t take more than a minute.\nThanks for your support!"
#define str_Share                                    @"Share"
#define str_Done                                     @"Done"





#endif /* Constants_h */
