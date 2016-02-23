//
//  AppDelegate.m
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/16/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Managers.h"
#import <Tapjoy/Tapjoy.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Branch/Branch.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
    }];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:PARSE_APP_ID
                  clientKey:PARSE_CLIENT_KEY];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [Fabric with:@[[Twitter class]]];

    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

    if ([[ver objectAtIndex:0] intValue] >= 7) {
        [[UINavigationBar appearance] setBarTintColor:NAVBAR_COLOR];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTranslucent:NO];
    }else {
        [[UINavigationBar appearance] setTintColor:NAVBAR_COLOR];
    }
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectSuccess:)
                                                 name:TJC_CONNECT_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectFail:)
                                                 name:TJC_CONNECT_FAILED
                                               object:nil];
    [Tapjoy setDebugEnabled:NO];

    [Tapjoy connect:TAPJOY_CONNECT_KEY];
    

    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [[Branch getInstance] handleDeepLink:url];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

-(void)tjcConnectSuccess:(NSNotification*)notifyObj{}
-(void)tjcConnectFail:(NSNotification*)notifyObj{}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
