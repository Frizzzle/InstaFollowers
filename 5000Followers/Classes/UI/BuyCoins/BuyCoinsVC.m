//
//  BuyCoinsVC.m
//  5000Followers
//
//  Created by Koctya on 11/24/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "BuyCoinsVC.h"
#import "BuyCoinsHeaderTVC.h"
#import "BuyCoinsMainTVC.h"
#import "buyCoinsModel.h"
#import <InstagramKit.h>
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "RoundedButton.h"
#import <JTImageButton/JTImageButton.h>
#import <Parse/Parse.h>
#import "Helper.h"
#import <Foundation/Foundation.h>
#import "buyFollowersModel.h"

#import "Managers.h"


@interface BuyCoinsVC()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *coinsCountLb;
@property NSMutableArray* coins;
@property NSMutableArray* followers;
@end

@implementation BuyCoinsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [Helper changeBackgroundWithContext:self];
    self.coins = [[NSMutableArray alloc] init];
    self.followers = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self getUserProfilePicture];
    [self loadUserCoins];
    [self loadFollowersFromParse];

}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:false];
    [self getUserCoins];
}

-(void) cancelAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil ];
}
#pragma mark Tapjoy

- (IBAction)freeCoinsAction:(id)sender {
    [self getFreeCoins];
}
- (IBAction)powerFollowAction:(id)sender {
    [self powerFollow];
}

-(void) getFreeCoins {
    TJPlacement *p = [TJPlacement placementWithName:str_FreeCoins delegate:self ];
    [p requestContent];
}

- (void)requestDidSucceed:(TJPlacement*)placement{
    if(placement.isContentAvailable == NO) {
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
        [Helper showAlertViewWithContext:self title:str_Disabled message:@"" style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
        return;
    }
    [placement showContentWithViewController:self];
    
}  
- (void)requestDidFail:(TJPlacement*)placement error:(NSError*)error{
}
- (void)contentIsReady:(TJPlacement*)placement{
} 
- (void)contentDidAppear:(TJPlacement*)placement{

}
- (void)contentDidDisappear:(TJPlacement*)placement{
    [[TapJoyManager sharedManager] getEarnedDeltaWithCompletion:^(int earnedCount) {
        if(earnedCount > 0) {
            [[UserManager sharedManager] increaseUserCoins:earnedCount onSuccess:^{
                [self getUserCoins];
                [Tapjoy showDefaultEarnedCurrencyAlert];
            } onFailure:^(NSError * error) {
                
            }];
        }
        
        
    }];
    
}
-(void) powerFollow {
    if([UserManager sharedManager].isPowerFollowEnabled == NO) {
        buyCoinsModel* selectedCoins = self.coins[1];
        [[PurchasesManager sharedManager] buyCoinsWithId:selectedCoins.inapp_id onSuccess:^{
            [[UserManager sharedManager] increaseUserCoins:selectedCoins.coins onSuccess:^{
                [[UserManager sharedManager] enablePowerFollow];
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
                [Helper showAlertViewWithContext:self title:str_Purchase_successful message:str_PFa style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
            } onFailure:^(NSError * error) {
                
            }];
        } onFailure:^(NSError *error) {
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
            
            [Helper showAlertViewWithContext:self title:str_Failure message:str_Purchase_failure style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
        }];
        
        return;
    }
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
    [Helper showAlertViewWithContext:self title:str_Power_Follow message:str_Activated style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
    return;
    
}


#pragma mark Get_User_Info

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
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:coins];
    self.navigationItem.rightBarButtonItem=barButton;
    
    self.coinsCountLb.text = [NSString stringWithFormat:@"%d",(int)countCoins];
    
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
        [signOut addTarget:self action:@selector(accountAction:)
          forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=barButton;
    } failure:^(NSError *error, NSInteger serverStatusCode) {
    }];
}
-(IBAction)accountAction:(id)sender  {
}

#pragma mark Loaders
-(void) loadPriceList {
    
    NSMutableArray* inAppIdArr = [[NSMutableArray alloc] init];
    for (buyCoinsModel* item in self.coins) {
        if(item.inapp_id != nil) {
            [inAppIdArr addObject:item.inapp_id];
        }else {
            [inAppIdArr addObject:@""];
        }
        
    }
    NSSet* inAppIdSet = [[NSSet alloc] initWithArray:inAppIdArr];
    [[PurchasesManager sharedManager] getPriceWithProducts:inAppIdSet onSuccess:^(NSArray *objects , NSArray * invalidObjects) {
            for (int i = 0; i < objects.count; i++) {
                SKProduct * product = (SKProduct *)objects[i];
                for (buyCoinsModel* item in self.coins) {
                    if([item.inapp_id isEqualToString:product.productIdentifier] ) {
                        [item setCoinsPrice:[NSString stringWithFormat:@"%@", product.price]];
                        break;
                    }
                }
            }
        [self.tableView reloadData];
    } onFailure:^(NSError *error) {
    }];
    
}
-(void) loadFollowersFromParse {
    PFQuery* buyFollowersQuery = [[PFQuery alloc] initWithClassName:BUY_COINS_CLASS];
    [buyFollowersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (PFObject* object in objects) {
            NSString* objectId = object.objectId;
            NSString *inapp_id = object[INAPP_ID];
            NSInteger coins = [object[COINS_FIELD] integerValue];
            NSInteger bonus = [object[BONUS_FIELD] integerValue];
            BOOL isBonusEnabled = [object[IS_BONUS_ENABLE_FIELD] boolValue];
            BOOL isMostPopular = [object[IS_MOST_POPULAR_FIELD] boolValue];
            BOOL isBestValue = [object[IS_BEST_VALUE_FIELD] boolValue];
            buyCoinsModel* item = [[buyCoinsModel alloc] initWithObjectId:objectId inapp_id:inapp_id coins:coins bonus:bonus isBonusEnabled:isBonusEnabled isMostPopular:isMostPopular isBestValue:isBestValue];
            [item setCoinsPrice:@""];
            [self.coins addObject:item];
        }
        PFQuery* buyFollowersQuery = [[PFQuery alloc] initWithClassName:BUY_FOLLOWERS_CLASS];
        [buyFollowersQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            for (PFObject* object in objects) {
                NSString* objectId = object.objectId;
                NSInteger followers = [object[FOLLOWERS_FIELD] integerValue];
                NSInteger coins = [object[COINS_FIELD] integerValue];
                NSInteger bonus = [object[BONUS_FIELD] integerValue];
                BOOL isBonusEnabled = [object[IS_BONUS_ENABLE_FIELD] boolValue];
                buyFollowersModel* item = [[buyFollowersModel alloc] initWithObjectId:objectId followers:followers coins:coins bonus:bonus isBonusEnabled:isBonusEnabled];
                [self.followers addObject:item];
            }
            [self.tableView reloadData];
            [self loadPriceList];
        }];
    }];
}

-(void) loadUserCoins {
    PFQuery* getUserCoinsQuery = [[PFQuery alloc] initWithClassName:USER_COINS_CLASS];
    [getUserCoinsQuery whereKey:USER_ID equalTo:[PFUser currentUser]];
    [getUserCoinsQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSInteger countCoins = [object[COINS_FIELD] integerValue];
        self.coinsCount = countCoins;
        self.coinsCountLb.text = [NSString stringWithFormat:@"%ld",(long)self.coinsCount];
        [self.tableView reloadData];
    }];
}


#pragma mark - UITableViewDataSource 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    buyCoinsModel* selectedCoins = self.coins[indexPath.row];
    [[PurchasesManager sharedManager] buyCoinsWithId:selectedCoins.inapp_id onSuccess:^{
        [[UserManager sharedManager] increaseUserCoins:selectedCoins.coins onSuccess:^{
            [self getUserCoins];
        } onFailure:^(NSError * error) {
            
        }];
    } onFailure:^(NSError *error) {
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
        
        [Helper showAlertViewWithContext:self title:str_Failure message:str_Purchase_failure style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BuyCoinsMainTVC* cell = [tableView dequeueReusableCellWithIdentifier:@"Main"];
    if([self.followers count] == 0) {
        return cell;
    }
    buyCoinsModel* currentObjectC = (buyCoinsModel*)self.coins[indexPath.row ];
    buyFollowersModel* currentObjectF = (buyFollowersModel*)self.followers[indexPath.row];
    if(currentObjectC.bonus != 0 && currentObjectC.isBonusEnabled == YES) {
        cell.coinsLbl.text = [NSString stringWithFormat:str_Buy2,(int)currentObjectC.coins,(int)currentObjectC.bonus];
        
    }else {
        cell.coinsLbl.text = [NSString stringWithFormat:str_Buy,(int)currentObjectC.coins];
    }
    cell.followersLbl.text = [NSString stringWithFormat:str_For,(int)currentObjectF.followers];

    if([currentObjectC.price isEqualToString:@""]) {
        cell.priceLbl.text = @"";
        return cell;
    }
    cell.priceLbl.text = [NSString stringWithFormat:@"$%@",(NSString *) currentObjectC.price];
    
    if(currentObjectC.isMostPopular == YES) {
        cell.flagImage.image = [UIImage imageNamed:ICON_MOST_POPULAR];
    }else if(currentObjectC.isBestValue == YES) {
        cell.flagImage.image = [UIImage imageNamed:ICON_BEST_VALUE];
    }
    
    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coins.count;
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma end

@end
