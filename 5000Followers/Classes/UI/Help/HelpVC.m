//
//  HelpVC.m
//  5000Followers
//
//  Created by Koctya on 1/18/16.
//  Copyright © 2016 Pro.Code. All rights reserved.
//

#import "HelpVC.h"
#import "Helper.h"
#import "Constants.h"
@interface HelpVC ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation HelpVC

-(void)viewDidLoad {
    [super viewDidLoad];
    [Helper changeBackgroundWithContext:self];
    self.navigationItem.title = str_Help;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * versionBuildString = [NSString stringWithFormat:str_Version, appVersionString, appBuildString];
    self.versionLabel.text = versionBuildString;
}

@end
