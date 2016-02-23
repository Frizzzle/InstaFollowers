//
//  Helper.m
//  5000Followers
//
//  Created by Koctya on 11/28/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "Helper.h"
#import "Constants.h"
#import <DLRadioButton/DLRadioButton.h>
@implementation Helper

+(void) showAlertViewWithContext:(UIViewController*) context title:(NSString*) title message:(NSString*) message style:(UIAlertControllerStyle) style actions:(NSMutableArray*) actions {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:style];
    
    for (UIAlertAction* action in actions) {
        [alert addAction:action];
    }
    [context presentViewController:alert animated:YES completion:nil];
}
+(void) changeBackgroundWithContext:(UIViewController* )controller {
    UIGraphicsBeginImageContext(controller.view.frame.size);
    [[UIImage imageNamed:str_background] drawInRect:controller.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    controller.view.backgroundColor = [UIColor colorWithPatternImage:image];
}
@end

