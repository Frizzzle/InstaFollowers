//
//  SetupCategoriesVC.h
//  5000Followers
//
//  Created by Koctya on 11/30/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeCategories.h"

@interface SetupCategoriesVC : UIViewController<UITableViewDataSource,UITableViewDelegate,setCategoryProtocol>
@property BOOL fromMain;

@end
