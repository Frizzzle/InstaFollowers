//
//  BuyCoinsVC.h
//  5000Followers
//
//  Created by Koctya on 11/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Tapjoy/Tapjoy.h>

@interface BuyCoinsVC : UIViewController<UITableViewDataSource,UITableViewDelegate,TJPlacementDelegate>
@property NSInteger coinsCount;
@end
