//
//  ChangeCategories.h
//  5000Followers
//
//  Created by Koctya on 12/1/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol setCategoryProtocol
- (void) selectedCategory:(NSArray* ) categories;
@end

@interface ChangeCategories : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property NSMutableArray* categories;
@property NSMutableArray* selectedCategories;
@property (nonatomic, weak, nullable) id <setCategoryProtocol> delegate;
@end
