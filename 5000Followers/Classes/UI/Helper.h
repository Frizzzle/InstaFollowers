//
//  Helper.h
//  5000Followers
//
//  Created by Koctya on 11/28/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helper : NSObject
+(void) showAlertViewWithContext:(UIViewController*) context title:(NSString*) title message:(NSString*) message style:(UIAlertControllerStyle) style actions:(NSMutableArray*) actions;
+(void) changeBackgroundWithContext:(UIViewController* )controller;
@end
