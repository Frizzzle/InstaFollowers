//
//  PurchasesManager.m
//  5000Followers
//
//  Created by Koctya on 11/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "PurchasesManager.h"

@implementation PurchasesManager

+ (PurchasesManager*) sharedManager {
    
    static PurchasesManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PurchasesManager alloc] init];
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


-(void) getPriceWithProducts:(NSSet* ) products onSuccess:(void(^) (NSArray*,NSArray*)) successCalb onFailure:(void(^)(NSError* error)) failureCalb {
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        successCalb(products,invalidProductIdentifiers);
    } failure:^(NSError *error) {
        failureCalb(error);
    }];
    
}

-(void) buyCoinsWithId:(NSString* ) inappID onSuccess:(void(^) ()) successCalb onFailure:(void(^)(NSError* error)) failureCalb {
    [[RMStore defaultStore] addPayment:inappID success:^(SKPaymentTransaction *transaction) {
        successCalb();
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        failureCalb(error);
    }];
    
}


@end
