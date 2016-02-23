//
//  CategoryManager.h
//  5000Followers
//
//  Created by Koctya on 12/28/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryManager : NSObject
+ (CategoryManager *) sharedManager;
@property NSMutableArray* ownCategories;
@property NSMutableArray* searchCategories;
@property NSMutableArray* categories;

-(void) getAllCategoriesOnLoad:(void(^) (NSMutableArray* )) onLoad;
-(void) getOwnCategoriesOnLoad:(void(^) (NSMutableArray* )) onLoad;
-(void) getSearchCategoriesOnLoad:(void(^) (NSMutableArray* )) onLoad;
-(void) updateCategoriesOwn:(NSArray*) ownCategories search:(NSArray*) searchCategories onFinish:(void(^) ()) finish ;\
-(void) logoutAction;
@end
