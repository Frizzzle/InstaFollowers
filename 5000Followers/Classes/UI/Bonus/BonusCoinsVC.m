//
//  BonusCoinsVC.m
//  5000Followers
//
//  Created by Koctya on 12/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "BonusCoinsVC.h"
#import "Helper.h"
#import "Managers.h"
#import "bonusRewardModel.h"
#import "BonusTVC.h"
#import <InstagramKit.h>
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "RoundedButton.h"
#import <JTImageButton/JTImageButton.h>
#import "BonusItemModel.h"


@interface BonusCoinsVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray* rewards;
@property NSMutableArray* pfobjects;
@property NSMutableArray* bonusArray;
@end

@implementation BonusCoinsVC

-(void)viewDidLoad {
    self.rewards = [[NSMutableArray alloc] init];
    self.pfobjects = [[NSMutableArray alloc] init];
    self.bonusArray = [[NSMutableArray alloc] init];
    [Helper changeBackgroundWithContext:self];
    [self loadRewards];
    [self getUserProfilePicture];
}

-(void) getUserProfilePicture {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    [engine getSelfUserDetailsWithSuccess:^(InstagramUser *user) {
        CGRect frameimg1 = CGRectMake(0, 0, 40, 40);
        RoundedButton *signOut=[[RoundedButton alloc]initWithFrame:frameimg1];
        signOut.roundedSize = frameimg1.size.width/2;
        [signOut setImageForState:UIControlStateNormal withURL:user.profilePictureURL];
        signOut.titleLabel.backgroundColor = [UIColor redColor];
        signOut.titleLabel.textColor = [UIColor whiteColor];
        signOut.titleLabel.text = str_account;
        [signOut setShowsTouchWhenHighlighted:YES];
        
        UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:signOut];
        self.navigationItem.leftBarButtonItem=barButton;
    } failure:^(NSError *error, NSInteger serverStatusCode) {
    }];
}
-(void) loadRewards {
    PFQuery* rewardsQuery = [[PFQuery alloc] initWithClassName:LEVEL_REWARD_CLASS];
    [rewardsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error == nil) {
            for (PFObject* object in objects) {
                int requiredLevel = (int)[object[REQUIRED_LEVEL_FIELD] integerValue];
                int reward = (int)[object[REWARD_FIELD] integerValue];
                [self.pfobjects addObject:object];
                [self.rewards addObject: [[bonusRewardModel alloc] initWithObjectId:object.objectId requiredLevel:requiredLevel reward:reward createAt:nil]];
            }
            [self.tableView reloadData];
        }
    }];
}


- (IBAction)plusButtonAction:(id)sender {
    [self.tabBarController setSelectedIndex:2];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden: NO animated:NO];
    [self.tableView reloadData];
    [self getUserCoins];
    
}
-(void) getUserCoins {
    NSInteger countCoins = [UserManager sharedManager].userCoins;
    CGRect frameimg1 = CGRectMake(-20, 0, 110, 35);
    JTImageButton *coins=[[JTImageButton alloc]initWithFrame:frameimg1];
    [coins createTitle:[NSString stringWithFormat:@"\t%d",(int)countCoins] withIcon:[UIImage imageNamed:str_coins_icon] font:[UIFont boldSystemFontOfSize:18] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    coins.bgColor = BUTTON_ALPHA;
    coins.padding = JTImageButtonPaddingSmall;
    coins.borderWidth = 0.0;
    coins.iconSide = JTImageButtonIconSideRight;
    coins.cornerRadius = coins.frame.size.height / 2;
    coins.iconColor = [UIColor whiteColor];
    coins.titleColor = [UIColor whiteColor];
    coins.titleLabel.font = [UIFont systemFontOfSize:10];
    coins.highlightAlpha = 0.0;
    [coins addTarget:self action:@selector(plusButtonAction:)
    forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:coins];
    self.navigationItem.rightBarButtonItem=barButton;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rewards.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BonusTVC* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(![cell.subtitleLbl.text  isEqual: @""]) {
        long coins = [cell.rewardLbl.text integerValue];
        [[BonusManager sharedManager] receiveReward:(PFObject*)self.pfobjects[indexPath.row] onFinish:^{
            bonusRewardModel* item = (bonusRewardModel*) self.rewards[indexPath.row];
            [self addToBonusArrItem:item cell:cell];
            [[UserManager sharedManager] increaseUserCoins:coins onSuccess:^{
                [self getUserCoins];
            } onFailure:^(NSError *err) {
                
            }];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
            [Helper showAlertViewWithContext:self title:str_Coins_Awarded message:[NSString stringWithFormat:str_YHBAC,cell.rewardLbl.text] style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
            
        }];
        }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BonusTVC* cell = [tableView dequeueReusableCellWithIdentifier:@"BonusTVC"];
    bonusRewardModel* item = (bonusRewardModel*) self.rewards[indexPath.row];
    cell.titleLbl.text = [NSString stringWithFormat:str_LDR,(long)item.requiredLevel];
    cell.subtitleLbl.text = [NSString stringWithFormat:str_TTCR];
    cell.rewardLbl.text = [NSString stringWithFormat:@"%ld",(long)item.reward];
    cell.maskLbl.hidden = YES;
    cell.rewardLbl.hidden = NO;
    cell.coinsIcon.hidden = NO;
    if([LevelManager sharedManager].userLevel < item.requiredLevel) {
        cell.maskLbl.text = [NSString stringWithFormat:str_Low_Level];
        cell.maskLbl.hidden = NO;
        cell.rewardLbl.hidden = YES;
        cell.coinsIcon.hidden = YES;
        cell.subtitleLbl.text = @"";
    }
    [self addToBonusArrItem:item cell:cell];
    return cell;
}

-(void) addToBonusArrItem:(bonusRewardModel*) bonusItem cell:(BonusTVC*) cell {
    for (bonusRewardModel* rew in [BonusManager sharedManager].userRewards) {
        if([rew.objectId isEqualToString:bonusItem.objectId]) {
            cell.maskLbl.hidden = NO;
            cell.rewardLbl.hidden = YES;
            cell.coinsIcon.hidden = YES;
            cell.subtitleLbl.text = @"";
            cell.maskLbl.text = @"";
            for (BonusItemModel* item in self.bonusArray) {
                if(item.requiredLevel == rew.requiredLevel) {
                    item.date = [NSDate date];
                    [item reloadBonus];
                    return;
                }
            }
            BonusItemModel* item = [[BonusItemModel alloc] initWithRequiredLevel:rew.requiredLevel timerCell:cell date:rew.createAt];
            [self.bonusArray addObject:item];
        }
    }
}
@end
