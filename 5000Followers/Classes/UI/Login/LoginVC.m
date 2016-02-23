//
//  LoginVC.m
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/18/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "LoginVC.h"
#import <InstagramKit.h>
#import <ParseUI/ParseUI.h>
#import <PFQuery.h>
#import "SetupCategoriesVC.h"
#import "Managers.h"
#import "Helper.h"

@interface LoginVC () 
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end


@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOGIN_TITLE;
    [Helper changeBackgroundWithContext:self];
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    [self.navigationItem setHidesBackButton:YES];

    self.webView.scrollView.bounces = NO;
    
    InstagramKitLoginScope scope = InstagramKitLoginScopePublic | InstagramKitLoginScopeBasic | InstagramKitLoginScopeRelationships   | InstagramKitLoginScopeFollowersList ;
    NSURL *authURL = [[InstagramEngine sharedEngine] authorizationURLForScope:scope];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];

}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSError *error;
    if ([[InstagramEngine sharedEngine] receivedValidAccessTokenFromURL:request.URL error:&error])
    {
        [self getUser];
    }
    return YES;
}

-(void) getUser {
    [[UserManager sharedManager] setUserOnSuccess:^(bool state) {
        [self authenticationSuccess];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:@"" delegate:self cancelButtonTitle:OK_RETRY otherButtonTitles: nil];
        [alert show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self getUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:true];
}

- (void)authenticationSuccess
{
    [self performSegueWithIdentifier:SEGUE_SETUP sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_SETUP]) {
        SetupCategoriesVC* vc = [segue destinationViewController];
        vc.fromMain = NO;
    }
}


@end
