//
//  CategoryManager.m
//  5000Followers
//
//  Created by Koctya on 12/28/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "CategoryManager.h"
#import <Parse/Parse.h>
#import "Managers.h"

@interface CategoryManager ()
@property int categoriesState;
@property int ownCategoriesState;
@property int searchCategoriesState;
@property int updateState;
@end

@implementation CategoryManager
+ (CategoryManager*) sharedManager {
    
    static CategoryManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CategoryManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.categories = [[NSMutableArray alloc] init];
        self.ownCategories = [[NSMutableArray alloc] init];
        self.searchCategories = [[NSMutableArray alloc] init];
        self.categoriesState = NOT_LOADED;
        self.ownCategoriesState = NOT_LOADED;
        self.searchCategoriesState = NOT_LOADED;
        [self loadCategory];
        [self loadOwnCategory];
        [self loadsearchCategory];
    }
    return self;
}
-(void) logoutAction {
    self.ownCategories = [[NSMutableArray alloc] init];
    self.searchCategories = [[NSMutableArray alloc] init];
    self.ownCategoriesState = NOT_LOADED;
    self.categoriesState = LOGOUT_LOAD;
    self.searchCategoriesState = NOT_LOADED;

}

-(void) updateCategoriesOwn:(NSArray*) ownCat search:(NSArray*) searchCat onFinish:(void(^) ()) finish {
    [self.ownCategories removeAllObjects];
    NSMutableArray* ownArr = [[NSMutableArray alloc] init];
    NSMutableArray* searchArr = [[NSMutableArray alloc] init];
    for (NSString* cat in ownCat) {
        [self.ownCategories addObject:cat];
        [ownArr addObject:cat];
    }
    [self.searchCategories removeAllObjects];
    for (NSString* cat in searchCat) {
        [self.searchCategories  addObject:cat];
        [searchArr addObject:cat];
    }
    
    [self changeCategoryWithUserId:[PFUser currentUser] names:ownArr class:LOCAL_OWN_CATEGORIES_CLASS RemoteByClass:USER_OWN_CATEGORIES_CLASS callback:^{
        
    }];
    [self changeCategoryWithUserId:[PFUser currentUser] names:searchArr class:LOCAL_SEARCH_CATEGORIES_CLASS RemoteByClass:USER_SEARCH_CATEGORIES_CLASS callback:^{
        finish();
    }];

}

-(void) changeCategoryWithUserId:(PFUser*) userId names:(NSArray*) names class:(NSString* ) localClassName RemoteByClass:(NSString* ) remoteClassName callback:(void(^) ()) callback {
    if(names == nil) {
        return;
    }else {
        if(names.count == 0){
            return;
        }
    }
    NSString* catId = CATEGORIES_NAME_FIELD;
    
    PFQuery *categoryQuery = [PFQuery queryWithClassName:CATEGORIES_CLASS];
    [categoryQuery whereKey:catId containedIn:names];
    
    
    
    [categoryQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable categories, NSError * _Nullable error) {
        if(error != nil) {
        }
        PFQuery* userSearchCategQuery = [[PFQuery alloc] initWithClassName:remoteClassName];
        [userSearchCategQuery whereKey:USER_ID equalTo: [PFUser currentUser]];
        [userSearchCategQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objts, NSError * _Nullable error) {
            if(error != nil) {
            }
            for (PFObject* obj in objts) {
                [obj deleteInBackground];
            }
            NSMutableArray* pfObjects = [[NSMutableArray alloc] init];
            for (PFObject* categ in categories) {
                PFObject* newRecord = [[PFObject alloc] initWithClassName:remoteClassName];
                newRecord[USER_ID] = [PFUser currentUser];
                newRecord[CATEGORIES_FIELD] = categ;
                newRecord[INSTAGRAM_ID_FIELD] = [PFUser currentUser][INSTAGRAM_ID_FIELD];
                [pfObjects addObject:newRecord];
            }
            [PFObject saveAllInBackground:pfObjects block:^(BOOL succeeded, NSError * _Nullable error) {
                callback();
            }];
        }];
        
    }];
}

-(void) registerLocalCategoryByClass:(NSString* ) localClassName RemoteByClass:(NSString* ) remoteClassName type:(int) type {
    PFQuery* remoteCategories = [[PFQuery alloc] initWithClassName:remoteClassName];
    if(type != 0) {
        [remoteCategories whereKey:USER_ID equalTo:[PFUser currentUser]];
        [remoteCategories includeKey:CATEGORIES_FIELD];
    }
    [remoteCategories findObjectsInBackgroundWithBlock:^(NSArray * _Nullable categoriess, NSError * _Nullable error) {
        for (PFObject* category in categoriess) {
            if(type != 0) {
                PFObject* obg = category[CATEGORIES_FIELD];
                [self addObject:obg[CATEGORIES_NAME_FIELD] toArray:type];
                PFObject* localCategory = [[PFObject alloc] initWithClassName:localClassName];
                localCategory[CATEGORIES_NAME_FIELD] = obg[CATEGORIES_NAME_FIELD];
                [localCategory pinInBackground];
            }else {
                [self addObject:category[CATEGORIES_NAME_FIELD] toArray:type];
                PFObject* localCategory = [[PFObject alloc] initWithClassName:localClassName];
                localCategory[CATEGORIES_NAME_FIELD] = category[CATEGORIES_NAME_FIELD];
                [localCategory pinInBackground];
            }
        }
        [self changeStateByType:type state:LOADED];
    }];
}

-(void) changeStateByType:(int) type state:(int) state{
    switch (type) {
        case 0:
            self.categoriesState = state;
            break;
        case 1:
            self.ownCategoriesState = state;
            break;
        case 2:
            self.searchCategoriesState = state;
            break;
        default:
            break;
    }
}

-(NSMutableArray* ) getCategoryArrayFromObjects:(NSArray * _Nullable) objects type:(int) type {
    NSMutableArray* categoriesName = [[NSMutableArray alloc] init];
    for (PFObject* category in objects) {
        [categoriesName addObject: category[CATEGORIES_NAME_FIELD]];
        [self addObject:category[CATEGORIES_NAME_FIELD] toArray:type];
    }
    return categoriesName;
}

-(void) addObject:(NSString*) object toArray:(int) type {
    switch (type) {
        case 0:
            [self.categories addObject:object];
            break;
        case 1:
            [self.ownCategories addObject:object];
            break;
        case 2:
            [self.searchCategories addObject:object];
            break;
        default:
            break;
    }
}
-(void) removeAllInArray:(int) type {
    switch (type) {
        case 0:
            [self.categories removeAllObjects];
            break;
        case 1:
            [self.ownCategories removeAllObjects];
            break;
        case 2:
            [self.searchCategories removeAllObjects];
            break;
        default:
            break;
    }
}

-(void) checkExistingCategoryFromRemoteClass:(NSString* ) remoteClassName ToLocalClass:(NSString*) localClassName existingObjects:(NSArray * _Nullable) objects type:(int) type  {
    NSMutableArray* categoriesName = [self getCategoryArrayFromObjects:objects type:type];
    PFQuery* existCategories = [[PFQuery alloc] initWithClassName:remoteClassName];
    if(type != 0) {
        [existCategories whereKey:USER_ID equalTo:[PFUser currentUser]];
    }else {
        [existCategories whereKey:CATEGORIES_NAME_FIELD notContainedIn:categoriesName];
    }
    [existCategories countObjectsInBackgroundWithBlock:^(int number, NSError * _Nullable error) {
        switch (type) {
            case 0:
                if(number != 0) {
                    [self loadUpdatedCategoriesByRemote:remoteClassName local:localClassName existingObjects:objects type:type];
                }else {
                    [self changeStateByType:type state:LOADED];
                }
                break;
            case 1:
                if([self.ownCategories count] != number) {
                    [self loadUpdatedCategoriesByRemote:remoteClassName local:localClassName existingObjects:objects type:type];
                }else {
                    [self changeStateByType:type state:LOADED];
                }
                break;
            case 2:
                if([self.searchCategories count] != number) {
                    [self loadUpdatedCategoriesByRemote:remoteClassName local:localClassName existingObjects:objects type:type];
                }else {
                    [self changeStateByType:type state:LOADED];
                }
                break;
            default:
                break;
        }
        
        
        
    }];
    
}
-(void) loadUpdatedCategoriesByRemote:(NSString*) remoteClassName local:(NSString*) localClassName existingObjects:(NSArray * _Nullable) objects type:(int) type {
    PFQuery* remoteCategories = [[PFQuery alloc] initWithClassName:remoteClassName];
    if(type != 0) {
        [remoteCategories whereKey:USER_ID equalTo:[PFUser currentUser]];
        [remoteCategories includeKey:CATEGORIES_FIELD];
    }
    [remoteCategories findObjectsInBackgroundWithBlock:^(NSArray * _Nullable remoteObjects, NSError * _Nullable error) {
        [self removeAllInArray:type];
        [PFObject unpinAllInBackground:objects];
        for (PFObject* category in remoteObjects) {
            if(type != 0) {
                PFObject* obg = category[CATEGORIES_FIELD];
                [self addObject:obg[CATEGORIES_NAME_FIELD] toArray:type];
                PFObject* localCategory = [[PFObject alloc] initWithClassName:localClassName];
                localCategory[CATEGORIES_NAME_FIELD] = obg[CATEGORIES_NAME_FIELD];
                localCategory[USER_ID] = [PFUser currentUser];
                [localCategory pinInBackground];
            }else {
                [self addObject:category[CATEGORIES_NAME_FIELD] toArray:type];
                PFObject* localCategory = [[PFObject alloc] initWithClassName:localClassName];
                localCategory[CATEGORIES_NAME_FIELD] = category[CATEGORIES_NAME_FIELD];
                [localCategory pinInBackground];
            }
        }
        [self changeStateByType:type state:LOADED];
        
    }];
}
-(void) checkExistingCategoryFromRemoteClass:(NSString* ) remoteClassName ToLocalClass:(NSString*) localClassName existingObjects:(NSArray * _Nullable) objects   {
    
}
-(void) loadCategory {
    [self loadCategoryFromLocalClass:CATEGORIES_LOCAL_CLASS OrRemoteClassName:CATEGORIES_CLASS type:0];
}

-(void) loadCategoryFromLocalClass:(NSString*) localClassName OrRemoteClassName:(NSString*) remoteClassName type:(int) type {
    PFQuery* localCategories = [[PFQuery alloc] initWithClassName:localClassName];
    [localCategories fromLocalDatastore];
    
    [localCategories findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if([objects count] == 0) {
            [self registerLocalCategoryByClass:localClassName RemoteByClass:remoteClassName type:type];
        }else {
            [self checkExistingCategoryFromRemoteClass:remoteClassName ToLocalClass:localClassName existingObjects:objects type:type];
        }
        
    }];
}

-(void) loadsearchCategory {
    [self loadCategoryFromLocalClass:LOCAL_SEARCH_CATEGORIES_CLASS OrRemoteClassName:USER_SEARCH_CATEGORIES_CLASS type:2];
}

-(void) loadOwnCategory {
    
    [self loadCategoryFromLocalClass:LOCAL_OWN_CATEGORIES_CLASS OrRemoteClassName:USER_OWN_CATEGORIES_CLASS type:1];
}


-(void) getAllCategoriesOnLoad:(void(^) (NSMutableArray* )) onLoad {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if(self.categoriesState == LOGOUT_LOAD) {
            [self loadCategory];
            [self loadOwnCategory];
            [self loadsearchCategory];
            self.categoriesState = NOT_LOADED;
        }
        while (self.categoriesState != LOADED) {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            onLoad(self.categories);
        });
    });
}
-(void) getOwnCategoriesOnLoad:(void(^) (NSMutableArray* )) onLoad {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        while (self.ownCategoriesState != LOADED) {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            onLoad(self.ownCategories);
        });
    });
}
-(void) getSearchCategoriesOnLoad:(void(^) (NSMutableArray* )) onLoad {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        while (self.searchCategoriesState != LOADED) {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            onLoad(self.searchCategories);
        });
    });
}
@end
