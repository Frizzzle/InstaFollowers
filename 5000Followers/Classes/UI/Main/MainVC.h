//
//  MainVC.h
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/18/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CustomIOSAlertView/CustomIOSAlertView.h>
#import <Tapjoy/Tapjoy.h>

@interface MainVC : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,CustomIOSAlertViewDelegate,TJCVideoAdDelegate,TJPlacementDelegate>

@end
