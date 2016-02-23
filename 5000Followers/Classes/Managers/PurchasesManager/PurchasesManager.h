//
//  PurchasesManager.h
//  5000Followers
//
//  Created by Koctya on 11/25/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RMStore/RMStore.h>

@interface PurchasesManager : NSObject
+ (PurchasesManager *) sharedManager;

-(void) buyCoinsWithId:(NSString* ) inappID onSuccess:(void(^) ()) successCalb onFailure:(void(^)(NSError* error)) failureCalb;
-(void) getPriceWithProducts:(NSSet* ) products onSuccess:(void(^) (NSArray*,NSArray*)) successCalb onFailure:(void(^)(NSError* error)) failureCalb;

@end
