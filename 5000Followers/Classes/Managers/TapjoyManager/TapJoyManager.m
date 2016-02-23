//
//  TapJoyManager.m
//  5000Followers
//
//  Created by Koctya on 2/1/16.
//  Copyright © 2016 Pro.Code. All rights reserved.
//

#import "TapJoyManager.h"
#import "Managers.h"
@interface TapJoyManager ()
@property int tapjoyCoinsCount;
@end

@implementation TapJoyManager

+ (TapJoyManager*) sharedManager {
    
    static TapJoyManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TapJoyManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)synchronizeCoinsOnTapJoy {
    [Tapjoy getCurrencyBalanceWithCompletion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
        } else {
            int tapJoyCount = [parameters[@"amount"] intValue];
            int userCoins = [[UserManager sharedManager] userCoins];
            int delta = 0;
            if(tapJoyCount > userCoins) {
                delta = tapJoyCount - userCoins;
                [Tapjoy spendCurrency:delta completion:^(NSDictionary *parameters, NSError *error) {
                    if (error) {
                    } else {
                        self.tapjoyCoinsCount = [parameters[@"amount"] intValue];
                    }
                }];
            }else if(tapJoyCount < userCoins) {
                delta = userCoins - tapJoyCount;
                [Tapjoy awardCurrency:delta completion:^(NSDictionary *parameters, NSError *error) {
                    if (error) {
                    } else {
                    }
                    self.tapjoyCoinsCount = [parameters[@"amount"] intValue];
                }];
            }else {
                self.tapjoyCoinsCount = userCoins;
                return;
            }

        }
    }];
}

-(void) getEarnedDeltaWithCompletion:(void(^) (int earnedCount)) callback {
    [Tapjoy getCurrencyBalanceWithCompletion:^(NSDictionary *parameters, NSError *error) {
        if (error) {
        } else {
            int tapJoyCount = [parameters[@"amount"] intValue];
            int delta = tapJoyCount  - self.tapjoyCoinsCount;
            self.tapjoyCoinsCount = tapJoyCount;
            callback(delta);
            
        }
    }];
}
@end
