//
//  ShareVC.m
//  5000Followers
//
//  Created by Koctya on 1/22/16.
//  Copyright © 2016 Pro.Code. All rights reserved.
//

#import "ShareVC.h"
#import <FBSDKShareKit/FBSDKShareButton.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <JTImageButton/JTImageButton.h>
#import "Constants.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "Helper.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"
#import "Managers.h"

@interface ShareVC ()
@property (weak, nonatomic) IBOutlet JTImageButton *FBShareBtmMask;
@property (weak, nonatomic) IBOutlet JTImageButton *EmailShareBtn;
@property (weak, nonatomic) IBOutlet JTImageButton *CopyBtn;
@property (weak, nonatomic) IBOutlet UILabel *linkLbl;
@property (weak, nonatomic) IBOutlet JTImageButton *TwtSharebtn;

@property (strong, nonatomic) BranchUniversalObject *branchUniversalObject;

@property (weak, nonatomic) IBOutlet FBSDKShareButton *FBShareBtn;
@end

@implementation ShareVC

-(void)viewDidLoad {
    [super viewDidLoad];
    [Helper changeBackgroundWithContext:self];
    self.branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:[PFUser currentUser][INSTAGRAM_ID_FIELD]];
    self.branchUniversalObject.title = @"Get a Insta Followers";

    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    
    [self.branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *err) {
        [self.linkLbl setText:url];
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:self.linkLbl.text];
        self.FBShareBtn.shareContent = content;
    }];
    
    self.navigationItem.title = str_Share;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[Twitter sharedInstance] startWithConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET_KEY];
    [Fabric with:@[[Twitter sharedInstance]]];
    

    
    
    [self.EmailShareBtn createTitle:[NSString stringWithFormat:str_ShareE] withIcon:[UIImage imageNamed:@""] font:[UIFont boldSystemFontOfSize:14] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.EmailShareBtn.bgColor = BUTTON_GREEN;
    self.EmailShareBtn.padding = JTImageButtonPaddingNone;
    self.EmailShareBtn.borderWidth = 0.0;
    self.EmailShareBtn.iconSide = JTImageButtonIconSideLeft;
    self.EmailShareBtn.cornerRadius = self.EmailShareBtn.frame.size.height / 10;
    self.EmailShareBtn.iconColor = [UIColor whiteColor];
    self.EmailShareBtn.titleColor = [UIColor whiteColor];
    
    [self.CopyBtn createTitle:[NSString stringWithFormat:str_CTC] withIcon:[UIImage imageNamed:@""] font:[UIFont boldSystemFontOfSize:14] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.CopyBtn.bgColor = BUTTON_PINK;
    self.CopyBtn.padding = JTImageButtonPaddingBig;
    self.CopyBtn.borderWidth = 0.0;
    self.CopyBtn.iconSide = JTImageButtonIconSideLeft;
    self.CopyBtn.cornerRadius = self.CopyBtn.frame.size.height / 10;
    self.CopyBtn.iconColor = [UIColor whiteColor];
    self.CopyBtn.titleColor = [UIColor whiteColor];
    
    [self.TwtSharebtn createTitle:[NSString stringWithFormat:str_SBT] withIcon:[UIImage imageNamed:@""] font:[UIFont boldSystemFontOfSize:14] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.TwtSharebtn.bgColor = BUTTON_BLUE_TWITTER;
    self.TwtSharebtn.padding = JTImageButtonPaddingBig;
    self.TwtSharebtn.borderWidth = 0.0;
    self.TwtSharebtn.iconSide = JTImageButtonIconSideLeft;
    self.TwtSharebtn.cornerRadius = self.TwtSharebtn.frame.size.height / 10;
    self.TwtSharebtn.iconColor = [UIColor whiteColor];
    self.TwtSharebtn.titleColor = [UIColor whiteColor];
    
    [self.FBShareBtmMask createTitle:[NSString stringWithFormat:str_SBF] withIcon:[UIImage imageNamed:@""] font:[UIFont boldSystemFontOfSize:14] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.FBShareBtmMask.bgColor = BUTTON_BLUE_FACEBOOK;
    self.FBShareBtmMask.padding = JTImageButtonPaddingBig;
    self.FBShareBtmMask.borderWidth = 0.0;
    self.FBShareBtmMask.iconSide = JTImageButtonIconSideLeft;
    self.FBShareBtmMask.cornerRadius = self.TwtSharebtn.frame.size.height / 10;
    self.FBShareBtmMask.iconColor = [UIColor whiteColor];
    self.FBShareBtmMask.titleColor = [UIColor whiteColor];
}
- (IBAction)facebookAction:(id)sender {
    [self.FBShareBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)mailAction:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Followers App Link"];
        [mail setMessageBody:self.linkLbl.text isHTML:NO];
        [mail setToRecipients:@[@""]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
    }
}

- (IBAction)tweetAction:(id)sender {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            TWTRComposer *composer = [[TWTRComposer alloc] init];
            
            [composer setText:self.linkLbl.text];
            [composer setImage:[UIImage imageNamed:@"fabric"]];
            [composer showFromViewController:self completion:^(TWTRComposerResult result) {
                if (result == TWTRComposerResultCancelled) {
                }
                else {
                }
            }];
        } else {
        }
    }];
}

- (IBAction)copyAction:(id)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.linkLbl.text];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
