//
//  SplashVC.m
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/18/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "SplashVC.h"
#import <InstagramKit.h>
#import "Managers.h"
#import "Helper.h"

@interface SplashVC ()

@property (nonatomic, weak) InstagramEngine *instagramEngine;

@end

@implementation SplashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [Helper changeBackgroundWithContext:self];
    self.instagramEngine = [InstagramEngine sharedEngine];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutEvent:)
                                                 name:NOTIF_LOGOUT_ACTION
                                               object:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getLoginStatus) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void) getLoginStatus {
    if (![self.instagramEngine isSessionValid]) {
        [self showLoginScreen];
    } else {
        [[UserManager sharedManager] setUserOnSuccess:^(bool state) {
            
            [[UserManager sharedManager] accountIsSetupWithUserId:[PFUser currentUser] isSet:^{
                [self showMainScreen];
            } isNotSet:^{
                [self showSetupScreen];
            }];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:@"" delegate:self cancelButtonTitle:OK_RETRY otherButtonTitles: nil];
            [alert show];
            
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self getLoginStatus];
}

-(void) showLoginScreen {
    [self performSegueWithIdentifier:SEGUE_LOGIN sender:self];
}
-(void) showSetupScreen {
    [self performSegueWithIdentifier:SEGUE_SETUP sender:self];
}

-(void) showMainScreen {
    [self performSegueWithIdentifier:SEGUE_MAIN sender:self];
}

- (void) logoutEvent:(NSNotification *) notification {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getLoginStatus) userInfo:nil repeats:NO];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true];
    [super viewWillAppear:animated];

}



@end
