//
//  MoreVC.m
//  5000Followers
//
//  Created by Koctya on 12/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "MoreVC.h"
#import "MoreTVC.h"
#import "Helper.h"
#import <InstagramEngine.h>
#import <UIKit/UIKit.h>
#import "SetupCategoriesVC.h"
#import "Managers.h"
#import "bonusRewardModel.h"





@implementation MoreVC

-(void)viewDidLoad {
    [Helper changeBackgroundWithContext:self];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_SETUP]) {
        SetupCategoriesVC* vc = [segue destinationViewController];
        vc.fromMain = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO animated:NO];
}

-(void) contactUs {
    if ([MFMailComposeViewController canSendMail])
    {
        UIDevice *aDevice = [UIDevice currentDevice];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        NSString *versionApp = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [mail setSubject:[NSString stringWithFormat:str_FF,versionApp]];
        NSString *versionDevice = [aDevice systemVersion];
        NSString *modelDevice = [aDevice model];
        [mail setMessageBody:[NSString stringWithFormat:str_FRI,versionApp,modelDevice,versionDevice] isHTML:NO];
        [mail setToRecipients:@[@"InstaFollowersFreellc@gmail.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
    }

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    UIAlertAction* buyCoins = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[InstagramEngine sharedEngine] logout];
        PFQuery* ownCategory = [[PFQuery alloc] initWithClassName:LOCAL_OWN_CATEGORIES_CLASS];
        [ownCategory findObjectsInBackgroundWithBlock:^(NSArray * _Nullable ownArr, NSError * _Nullable error) {
            [PFObject unpinAllInBackground:ownArr];
            PFQuery* ownCategory = [[PFQuery alloc] initWithClassName:LOCAL_OWN_CATEGORIES_CLASS];
            [ownCategory findObjectsInBackgroundWithBlock:^(NSArray * _Nullable searchArr, NSError * _Nullable error) {
                [PFObject unpinAllInBackground:searchArr];
                [[CategoryManager sharedManager] logoutAction];
                [[FollowersManager sharedManager] logoutAction];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LOGOUT_ACTION
                                                                    object:nil];
            }];
        }];
        
    }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:str_Cancel style:UIAlertActionStyleCancel handler:nil];
    switch (indexPath.row) {
        case MORE_EDIT_CATEGORIES_ROW:
            [self performSegueWithIdentifier:SEGUE_SETUP sender:self];
            break;
        case MORE_CONTACT_US_ROW:
            [self contactUs];
            break;
        case MORE_SHARE_ROW:
            [self performSegueWithIdentifier:@"Share" sender:self];
            break;
        case MORE_HELP_ROW:
            [self performSegueWithIdentifier:@"HelpVC" sender:self];
            break;
        case MORE_LOG_OUT_ROW:
            [Helper showAlertViewWithContext:self title:str_LogOUT message:@"" style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:buyCoins,cancelAction, nil]];
            
            break;
        default:
            break;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MORE_COUNT_ROWS;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoreTVC* cell = [tableView dequeueReusableCellWithIdentifier:@"MoreTVC"];
    switch (indexPath.row) {
        case MORE_EDIT_CATEGORIES_ROW:
            cell.moreLbl.text = MORE_EDIT_CATEGORIES_NAME;
            break;
        case MORE_CONTACT_US_ROW:
            cell.moreLbl.text = MORE_CONTACT_US_NAME;
            break;
        case MORE_SHARE_ROW:
            cell.moreLbl.text = MORE_SHARE_NAME;
            break;
        case MORE_HELP_ROW:
            cell.moreLbl.text = MORE_HELP_NAME;
            break;
        case MORE_LOG_OUT_ROW:
            cell.moreLbl.text = MORE_LOGOUT_NAME;
            break;
            
        default:
            break;
    }
    
    return cell;
}


@end
