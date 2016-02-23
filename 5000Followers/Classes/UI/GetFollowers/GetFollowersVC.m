//
//  GetFollowers.m
//  5000Followers
//
//  Created by Koctya on 11/23/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "GetFollowersVC.h"
#import "GetFollowersTVC.h"
#import <InstagramKit.h>
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "RoundedButton.h"
#import <JTImageButton/JTImageButton.h>
#import <Parse/Parse.h>
#import "buyFollowersModel.h"
#import "BuyCoinsVC.h"
#import "Managers.h"
#import "Helper.h"
@interface GetFollowersVC () 
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet JTImageButton *coinsBtn;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *countFollowerLbl;
@property (weak, nonatomic) IBOutlet UILabel *countFollowingLbl;
@property NSMutableArray* followers;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *countRemainFollowerLbl;
@property int userCoinsCount;
@end

@implementation GetFollowersVC



- (void)viewDidLoad{
    [super viewDidLoad];
    [Helper changeBackgroundWithContext:self];
    self.followers = [[NSMutableArray alloc] init];
    self.userCoinsCount = 0;
    [self initView];
}

- (void)initView {
    [self getUserProfilePicture];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
    [self.coinsBtn createTitle:@"" withIcon:[UIImage imageNamed:str_coins_icon] font:[UIFont boldSystemFontOfSize:15] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.coinsBtn.bgColor = [UIColor whiteColor];
    self.coinsBtn.padding = JTImageButtonPaddingMedium;
    self.coinsBtn.borderWidth = 2;
    self.coinsBtn.cornerRadius = self.coinsBtn.frame.size.height / 2;
    self.coinsBtn.iconColor = self.coinsBtn.borderColor;
    self.coinsBtn.titleColor = self.coinsBtn.borderColor;
    self.coinsBtn.highlightAlpha = 0.8;
    self.coinsBtn.iconSide = JTImageButtonIconSideRight;
    
    [self.coinsBtn addTarget:self action:@selector(showBuyCoins:)
    forControlEvents:UIControlEventTouchUpInside];
    [self.coinsBtn setShowsTouchWhenHighlighted:YES];

    
    [self loadFollowersFromParse];
    [self loadUserPictureImage];
    
}

-(void) loadFollowersFromParse {
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
    }];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false];
    [self getUserCoins];
    [self updateProgress];
}

-(void) updateProgress {
    if([UserManager sharedManager].followersLeft != 0) {
        self.progressView.hidden = false;
        self.countRemainFollowerLbl.text = [NSString stringWithFormat:@"%ld",(long)[UserManager sharedManager].followersLeft];
        float progress = (float)[UserManager sharedManager].followersLeft / [UserManager sharedManager].followersMaxCount;
        [self.progressBar setProgress:(1 - progress)];
    }else {
        self.progressView.hidden = true;
    }
    [[UserManager sharedManager] updateFollowersLeftOnFinish:^{
        if([UserManager sharedManager].followersLeft != 0) {
            self.progressView.hidden = false;
            self.countRemainFollowerLbl.text = [NSString stringWithFormat:@"%ld",(long)[UserManager sharedManager].followersLeft];
            float progress = (float)[UserManager sharedManager].followersLeft / [UserManager sharedManager].followersMaxCount;
            [self.progressBar setProgress:(1 - progress)];
        }else {
            self.progressView.hidden = true;
        }
    }];
}

-(void) loadUserPictureImage {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
    [engine getSelfUserDetailsWithSuccess:^(InstagramUser *user) {
        
        self.userImage.image = nil;
        [self.userImage setImageWithURL:user.profilePictureURL];
        self.userImage.layer.cornerRadius = self.userImage.frame.size.height/2;
        self.userImage.layer.masksToBounds = YES;
    } failure:^(NSError *error, NSInteger serverStatusCode) {
    }];
}

-(void) getUserCoins {
    NSInteger countCoins = [UserManager sharedManager].userCoins;
    self.userCoinsCount = (int) countCoins;
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
    
    
    [coins addTarget:self action:@selector(showBuyCoins:)
    forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:coins];
    self.navigationItem.rightBarButtonItem=barButton;
    
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
        
        self.userName.text = user.fullName;
        
        UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:signOut];
        [signOut addTarget:self action:@selector(accountAction:)
          forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=barButton;
    } failure:^(NSError *error, NSInteger serverStatusCode) {
    }];
}
-(IBAction)accountAction:(id)sender  {
}

-(void) showBuyCoins:(UIButton *)sender {
    [self.tabBarController setSelectedIndex:2];
}


#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    buyFollowersModel* currentFollowerPack = self.followers[indexPath.row];
    if(self.userCoinsCount < currentFollowerPack.coins) {
        UIAlertAction* buyCoins = [UIAlertAction actionWithTitle:str_Buy_coins style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showBuyCoins:nil];
        }];
        [self getUserCoins];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:str_Cancel style:UIAlertActionStyleCancel handler:nil];
        [Helper showAlertViewWithContext:self title:str_NEC message:@"" style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:buyCoins,cancelAction, nil]];
    }else {
        UIAlertAction* buyCoins = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[FollowersManager sharedManager] addUserToFollowersWithId:[[PFUser currentUser] objectForKey:INSTAGRAM_ID_FIELD] countFollowers:currentFollowerPack.followers + currentFollowerPack.bonus onSuccess:^{
                [[UserManager sharedManager] decreaseUserCoins:currentFollowerPack.coins onSuccess:^{
                    [self getUserCoins];
                    [self updateProgress];
                    UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
                    self.progressView.hidden = NO;
                    [Helper showAlertViewWithContext:self title:str_Order_Complete message:str_YOIC style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
                } onFailure:^(NSError * erorr) {
                    [self getUserCoins];
                    UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
                    [Helper showAlertViewWithContext:self title:str_Error message:erorr.domain style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
                }];
                
            } onFailure:^(NSError * error) {
                [self getUserCoins];
            }];

        }];
        [self getUserCoins];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:str_No style:UIAlertActionStyleDefault handler:nil];
        [Helper showAlertViewWithContext:self title:str_Get_Followers message:[NSString stringWithFormat:str_AYSUWTGF,currentFollowerPack.followers] style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:buyCoins,cancelAction, nil]];
        
        }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GetFollowersTVC *cell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([GetFollowersVC class])];
    if(self.followers.count == 0) {
        return cell; 
    }
    buyFollowersModel* currentObject = (buyFollowersModel*)self.followers[indexPath.row];
    if(currentObject.bonus > 0 && currentObject.isBonusEnabled == YES) {
        cell.countFollowers.text = [NSString stringWithFormat:@"%d + %d",(int)currentObject.followers,(int)currentObject.bonus];
    }else {
        cell.countFollowers.text = [NSString stringWithFormat:@"%d",(int)currentObject.followers];
    }
    cell.coinsCountLbl.text = [NSString stringWithFormat:@"%d",(int) currentObject.coins];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.followers.count ;
}

#pragma end


@end
