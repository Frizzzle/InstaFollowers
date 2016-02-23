//
//  MainVC.m
//  5000Followers
//
//  Created by Alexandr Chernyy on 11/18/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "MainVC.h"
#import <InstagramKit.h>
#import "UIButton+AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "RoundedButton.h"
#import <JTImageButton/JTImageButton.h>
#import <Parse/Parse.h>
#import "SetupCategoriesVC.h"
#import "BuyCoinsVC.h"
#import "Managers.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Helper.h"
#import "UserPhotosCVC.h"
#import <Tapjoy/TJPlacement.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface MainVC ()
@property (weak, nonatomic) IBOutlet UILabel *levelUpLevel;

@property (weak, nonatomic) IBOutlet UIView *levelUpView;
@property (weak, nonatomic) IBOutlet UILabel *userLevel;
@property (weak, nonatomic) IBOutlet UILabel *followersRemain;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet JTImageButton *addCoinsButton;
@property (weak, nonatomic) IBOutlet JTImageButton *skipButton;
@property (weak, nonatomic) IBOutlet JTImageButton *plusButtons;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLlb;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLbl;
@property (weak, nonatomic) IBOutlet UIView *empty;
@property MBProgressHUD* progressBar;
@property (nonatomic, retain) JTImageButton *coins;
@property (nonatomic, retain) NSMutableArray* userMediaPhotos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *PowerFollowLabel;
@property BOOL isPressed;
@property BOOL isTimerStart;
@property NSTimer* timer;
@property NSTimer* buttonBlock;
@property NSString* currentUserId;
@property BOOL afterLoading;

@end

@implementation MainVC
@synthesize coins;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isPressed = NO;
    self.isTimerStart = NO;
    self.afterLoading = NO;
    self.timer = nil;
    self.userMediaPhotos = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(remainChange:)
                                                 name:NOTIF_REMAIN_CHANGE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(levelUp:)
                                                 name:NOTIF_LEVEL_UP
                                               object:nil];
    if([LevelManager sharedManager].userLevel != -1) {
        self.followersRemain.text = [NSString stringWithFormat:str_FR,(long)[LevelManager sharedManager].userRemainFollowers];
        self.userLevel.text = [NSString stringWithFormat:str_Level,(long)[LevelManager sharedManager].userLevel];
    }
    [self getUserProfilePicture];
    [Helper changeBackgroundWithContext:self];
    UITabBarController *tabBarController = self.tabBarController;
    UITabBar *tabBar = tabBarController.tabBar;
    
    self.levelUpView.layer.cornerRadius = 5;

    UITabBarItem *earnCoins = [tabBar.items objectAtIndex:TAB_EARN_COINS];
    UITabBarItem *getFollowers = [tabBar.items objectAtIndex:TAB_GET_FOLLOWERS];
    UITabBarItem *buyCoins = [tabBar.items objectAtIndex:TAB_BUY_COINS];
    UITabBarItem *bonusCoins = [tabBar.items objectAtIndex:TAB_BONUS_COINS];

    earnCoins.image = [[UIImage imageNamed:ICON_EARN_COINS] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    getFollowers.image = [[UIImage imageNamed:ICON_GET_FOLLOWERS] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    buyCoins.image = [[UIImage imageNamed:ICON_BUY_COINS] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    bonusCoins.image = [[UIImage imageNamed:ICON_BONUS_COINS] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]init];
    
    [self.addCoinsButton createTitle:str_Follow withIcon:[UIImage imageNamed:str_coins_icon] font:[UIFont boldSystemFontOfSize:15] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.addCoinsButton.bgColor = BUTTON_ALPHA;
    self.addCoinsButton.padding = JTImageButtonPaddingSmall;
    self.addCoinsButton.borderWidth = 1.0;
    self.addCoinsButton.iconColor = [UIColor whiteColor];
    self.addCoinsButton.titleColor = [UIColor whiteColor];
    self.addCoinsButton.highlightAlpha = 0.8;
    self.addCoinsButton.borderColor = [UIColor whiteColor];
    self.addCoinsButton.iconSide = JTImageButtonIconSideRight;
    
    
    [self.skipButton createTitle:str_Skip withIcon:[UIImage imageNamed:str_icon_cross] font:[UIFont systemFontOfSize:15.0] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.skipButton.titleColor = BUTTON_ALPHA;
    self.skipButton.iconColor = [UIColor whiteColor];
    self.skipButton.padding = JTImageButtonPaddingMedium;
    self.skipButton.titleColor = [UIColor whiteColor];
    self.skipButton.borderWidth = 1.0;
    self.skipButton.borderColor = [UIColor whiteColor];
    self.skipButton.iconSide = JTImageButtonIconSideRight;

    
    [self.plusButtons createTitle:str_Video5 withIcon:[UIImage imageNamed:str_coins_icon] font:[UIFont boldSystemFontOfSize:15] iconHeight:JTImageButtonIconHeightDefault iconOffsetY:JTImageButtonIconOffsetYNone];
    self.plusButtons.bgColor = BUTTON_ALPHA;
    self.plusButtons.padding = JTImageButtonPaddingSmall;
    self.plusButtons.borderWidth = 1.0;
    self.plusButtons.iconColor = [UIColor whiteColor];
    self.plusButtons.titleColor = [UIColor whiteColor];
    self.plusButtons.borderColor = [UIColor whiteColor];
    self.plusButtons.highlightAlpha = 0.8;
    self.plusButtons.iconSide = JTImageButtonIconSideRight;
    
    Branch *branch = [Branch getInstance];
    if([[Branch getInstance] isUserIdentified] == YES) {
        int credits = (int)[[Branch getInstance] getCredits];
        if(credits > 0) {
            [self showRefferalDialog:credits];
            
        }else {
            [branch loadRewardsWithCallback:^(BOOL changed, NSError *err) {
                if (!err && changed) {
                    [self showRefferalDialog:credits];
                }
            }];
        }
    }
}
-(void) showRefferalDialog:(int)credits {
    
    [[Branch getInstance] redeemRewards:credits callback:^(BOOL changed, NSError *error) {
        [[UserManager sharedManager] increaseUserCoins:credits onSuccess:^{
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
            [Helper showAlertViewWithContext:self title:str_RFRU message:[NSString stringWithFormat:@"%d",credits] style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
        } onFailure:^(NSError *error) {
            
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([UserManager sharedManager].isPowerFollowEnabled == YES) {
        self.PowerFollowLabel.hidden = NO;
    }else {
        self.PowerFollowLabel.hidden = YES;
    }
    [[CategoryManager sharedManager] getOwnCategoriesOnLoad:^(NSMutableArray * ownCategories) {
        NSMutableString* filters = [[NSMutableString alloc] init];
        for (NSString* item in ownCategories) {
            [filters appendString:@"#"];
            [filters appendString:item];
            [filters appendString:@" "];
            
        }
        self.filterLabel.text = filters;
    }];
    [[CategoryManager sharedManager] getSearchCategoriesOnLoad:^(NSMutableArray * searchCategories) {
        NSMutableString* filters = [[NSMutableString alloc] init];
        for (NSString* item in searchCategories) {
            [filters appendString:@"#"];
            [filters appendString:item];
            [filters appendString:@" "];
        }
        self.categoryLabel.text = filters;
    }];
    [self.navigationController setNavigationBarHidden:false];
    [self getUserCoins];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCoinsEvent:)
                                                 name:NOTIF_UPDATE_COINS
                                               object:nil];
    [self checkFollowers];
    
}



-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_UPDATE_COINS object:nil];
}

#pragma mark Account_Coins_Methods

- (void) remainChange:(NSNotification *) notification {
    self.followersRemain.text = [NSString stringWithFormat:str_FR,(long)[LevelManager sharedManager].userRemainFollowers];
    self.userLevel.text = [NSString stringWithFormat:str_Level,(long)[LevelManager sharedManager].userLevel];
}

- (void) levelUp:(NSNotification *) notification {
    self.followersRemain.text = [NSString stringWithFormat:str_FR,(long)[LevelManager sharedManager].userRemainFollowers];
    self.userLevel.text = [NSString stringWithFormat:str_Level,(long)[LevelManager sharedManager].userLevel];
    self.levelUpLevel.text = [NSString stringWithFormat:@"%ld",(long)[LevelManager sharedManager].userLevel];
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    [alertView setContainerView:[self createLevelUpView]];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:str_OK,nil]];
    [alertView setDelegate:self];
    [alertView show];
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
        
        UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:signOut];
        [signOut addTarget:self action:@selector(accountAction:)
        forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem=barButton;
    } failure:^(NSError *error, NSInteger serverStatusCode) {
    }];
}
-(IBAction)accountAction:(id)sender  {
}

-(void) updateCoinsEvent:(NSNotification *) notif {
    [self getUserCoins];
}

-(void) getUserCoins {
    
    NSInteger countCoins = [UserManager sharedManager].userCoins;
    CGRect frameimg1 = CGRectMake(0, 0, 110, 35);
    if(!coins)
        coins=[[JTImageButton alloc]initWithFrame:frameimg1];
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
    coins.highlighted = NO;
    
    [coins addTarget:self action:@selector(showBuyCoins:)
    forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc]initWithCustomView:coins];
    self.navigationItem.rightBarButtonItem=barButton;
    
}

-(void) showBuyCoins:(UIButton *)sender {
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark Work_With_Followers

-(void) followToUser {
    [[FollowersManager sharedManager] getFollowersonSuccess:^(NSMutableArray *array) {
        if(array.count <=0) {
            self.empty.hidden = NO;
            return;
        }
        followersModel* newFollower = [[FollowersManager sharedManager] currentFollower];
        [[UserManager sharedManager] makeFollowToUser:newFollower.instagramId Id:self.currentUserId onSuccess:^{
            [[UserManager sharedManager] increaseUserCoins:5 onSuccess:^{
                [[FollowersManager sharedManager] getFollowersonSuccess:^(NSMutableArray *array) {
                    self.followersRemain.text = [NSString stringWithFormat:str_FR,(long)[LevelManager sharedManager].userRemainFollowers - 1];
                    [[LevelManager sharedManager] decreaseRemainFollowers];
                    if(array.count > 0) {
                        self.empty.hidden = YES;
                        [self getUserCoins];
                        [self nextFollower];
                        
                    }else {
                        [self.userMediaPhotos removeAllObjects];
                        [self.collectionView reloadData];
                        self.empty.hidden = NO;
                        
                        [self getUserCoins];
                    }
                }];
                
                
            } onFailure:^(NSError *error) {
                
            }];
        } onFailure:^(NSError * error) {
            
        }];
    }];

}

-(void) checkFollowers {
    [[FollowersManager sharedManager] getFollowersonSuccess:^(NSMutableArray *array) {
        if(array.count <=0) {
            [[FollowersManager sharedManager] loadFollowers];
            self.empty.hidden = NO;
            [self.userMediaPhotos removeAllObjects];
            [self.collectionView reloadData];
            self.afterLoading = YES;
        }else {
            [self currentFollower];
            self.empty.hidden = YES;
            
            
        }
    }];
}



-(void) getFollowerDetailsWithId:(NSString*) followerId {
    InstagramEngine *engine = [InstagramEngine sharedEngine];
     followersModel* current = [[FollowersManager sharedManager] getFollowerByName:followerId];
    if(current.userPhoto != nil && [current.userMedia count] != 0 &&current.followingCount != -1 && current.followerCount != -1 ) {
        [self.userImageView sd_setImageWithURL:current.userPhoto];
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
        self.userImageView.layer.masksToBounds = YES;
        
        self.followersCountLlb.text = [NSString stringWithFormat:@"%d",current.followerCount];
        self.followingCountLbl.text = [NSString stringWithFormat:@"%d",current.followingCount];
        
        self.userMediaPhotos = [[NSMutableArray alloc] initWithArray:current.userMedia];
        
        [self.collectionView reloadData];
        return;

    }
    [engine searchUsersWithString:followerId withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
        for (InstagramUser* user in users) {
            if([user.username isEqualToString:followerId]) {
                self.userImageView.image = nil;
                current.userPhoto = ((InstagramUser*)users[0]).profilePictureURL;
                [self.userImageView sd_setImageWithURL:current.userPhoto];
                
                self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
                self.userImageView.layer.masksToBounds = YES;
                if([((InstagramUser*)users[0]).fullName  isEqual: @""]) {
                    
                    self.nameLabel.text = ((InstagramUser*)users[0]).username;
                }else {
                    self.nameLabel.text = ((InstagramUser*)users[0]).fullName;
                }
                
                [engine getUserDetails:((InstagramUser*)users[0]).Id withSuccess:^(InstagramUser *user) {
                    current.followerCount = (int)user.followedByCount;
                    current.followingCount = (int)user.followsCount;
                    self.followersCountLlb.text = [NSString stringWithFormat:@"%d",current.followerCount];
                    self.followingCountLbl.text = [NSString stringWithFormat:@"%d",current.followingCount];
                } failure:^(NSError *error, NSInteger serverStatusCode) {
                    current.followerCount = 0;
                    current.followingCount = 0;
                    self.followersCountLlb.text = [NSString stringWithFormat:@"%d",0];
                    self.followingCountLbl.text = [NSString stringWithFormat:@"%d",0];
                }];
                self.currentUserId = ((InstagramUser*)users[0]).Id;
                [engine getMediaForUser:((InstagramUser*)users[0]).Id count:4 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                    [self.userMediaPhotos removeAllObjects];
                    if(media.count < 4) {
                        return;
                    }
                    for (InstagramMedia* item in media) {
                        if([self.currentUserId isEqualToString:item.user.Id]) {
                            [current.userMedia addObject:item.lowResolutionImageURL];
                            
                        } else {
                            [self.userMediaPhotos removeAllObjects];
                            [self.collectionView reloadData];
                            return;
                        }
                        
                    }
                    self.userMediaPhotos = [[NSMutableArray alloc] initWithArray:current.userMedia];
                    
                    [self.collectionView reloadData];
                } failure:^(NSError *error, NSInteger serverStatusCode) {
                    
                }];
                return;
            }
        }
        } failure:^(NSError *error, NSInteger serverStatusCode) {
        
    }];

}


-(UIView*) createLevelUpView {
    UIView* levelUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 210)];

    UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake(75,10,50,50)];
    [icon setImage:[UIImage imageNamed:str_blue_bonus]];
    [levelUpView addSubview:icon];
    
    UILabel* levelUpText = [[UILabel alloc] initWithFrame:CGRectMake(65, 70, 70, 21)];
    levelUpText.text = str_Level_Up;
    levelUpText.font = [UIFont systemFontOfSize:17];
    levelUpText.textColor= NAVBAR_COLOR;
    levelUpText.textAlignment = NSTextAlignmentCenter;
    [levelUpView addSubview:levelUpText];
    
    UILabel* levelUpNumberText = [[UILabel alloc] initWithFrame:CGRectMake(0, 106, 200, 51)];
    levelUpNumberText.text = [NSString stringWithFormat:@"%d",[LevelManager sharedManager].userLevel];
    levelUpNumberText.font = [UIFont systemFontOfSize:42];
    levelUpNumberText.textAlignment = NSTextAlignmentCenter;
    [levelUpView addSubview:levelUpNumberText];
    
    UILabel* coinsAwardedText = [[UILabel alloc] initWithFrame:CGRectMake(26, 172, 149, 21)];
    coinsAwardedText.text = str_100_Coins_Awarded;
    coinsAwardedText.font = [UIFont systemFontOfSize:17];
    coinsAwardedText.textColor= NAVBAR_COLOR;
    coinsAwardedText.textAlignment = NSTextAlignmentCenter;
    [levelUpView addSubview:coinsAwardedText];
    
    return levelUpView;
}

-(void) nextFollower {
    [self.userMediaPhotos removeAllObjects];
    [self.collectionView reloadData];
    followersModel* newFollower = [[FollowersManager sharedManager] getNextFollower];
    [[FollowersManager sharedManager] getFollowerDetails:newFollower withCallback:^(followersModel * user) {
        [self.userImageView sd_setImageWithURL:user.userPhoto];
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
        self.userImageView.layer.masksToBounds = YES;
        
        self.nameLabel.text = user.userName;
        
        self.followersCountLlb.text = [NSString stringWithFormat:@"%d",user.followerCount];
        self.followingCountLbl.text = [NSString stringWithFormat:@"%d",user.followingCount];
        
        self.userMediaPhotos = [[NSMutableArray alloc] initWithArray:user.userMedia];
        
        [self.collectionView reloadData];
        return;
    }];
}
-(void) currentFollower {

    if([FollowersManager sharedManager].updateState == LOADED) {
        [self.userMediaPhotos removeAllObjects];
        [self.collectionView reloadData];
        followersModel* newFollower = [[FollowersManager sharedManager] currentFollower];
        [[FollowersManager sharedManager] getFollowerDetails:newFollower withCallback:^(followersModel * user) {
            [self.userImageView sd_setImageWithURL:user.userPhoto];
            self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
            self.userImageView.layer.masksToBounds = YES;
            
            self.nameLabel.text = user.userName;
            
            self.followersCountLlb.text = [NSString stringWithFormat:@"%d",user.followerCount];
            self.followingCountLbl.text = [NSString stringWithFormat:@"%d",user.followingCount];
            
            self.userMediaPhotos = [[NSMutableArray alloc] initWithArray:user.userMedia];
            
            [self.collectionView reloadData];
            return;
        }];
        
    }

}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [[UserManager sharedManager] increaseUserCoins:100 onSuccess:^{
        [self getUserCoins];
    } onFailure:^(NSError *err) {
        
    }];
    [alertView close];
}
#pragma mark Button_Actions
- (IBAction)followDown:(id)sender {
    if([UserManager sharedManager].isPowerFollowEnabled == YES) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(powerFollow:)
                                       userInfo:nil
                                        repeats:YES];
        self.isPressed = YES;
        self.isTimerStart = NO;
        return;
    }
    

}


- (void)powerFollow:(NSTimer*)theTimer {
    self.isTimerStart = YES;
    if(self.isPressed == YES) {
        [self followToUser];
        return;
    }else {
        [self.timer invalidate];
    }
    
   
}

- (IBAction)followUp:(id)sender {
    if([UserManager sharedManager].isPowerFollowEnabled == NO) {
        [self followToUser];
        return;
    }
}

-(void) disableTimer {
    if(self.isTimerStart == YES) {
        self.isTimerStart = NO;
        [self.timer invalidate];
        self.timer = nil;
        self.isPressed = NO;
        return;
    }else if(self.isPressed == YES) {
        [self.timer invalidate];
        self.timer = nil;
        self.isPressed = NO;
        [self followToUser];
        return;
    }
}

- (IBAction)followCancel:(id)sender {
    [self disableTimer];
}
- (IBAction)followUpOutside:(id)sender {
    [self disableTimer];
}

- (IBAction)followHoldAction:(id)sender {
    
}

- (IBAction)skipButtonAction:(id)sender {
    [[FollowersManager sharedManager] getFollowersonSuccess:^(NSMutableArray *array) {
        if(array.count  > 1) {
            [self nextFollower];
        }else {
        }
    }];
}

#pragma mark Tapjoy
- (IBAction)plusButtonAction:(id)sender {
    [Tapjoy setVideoAdDelegate:self];
    
    TJPlacement *p = 	[TJPlacement placementWithName:str_Video delegate:self ];
    [p requestContent];
}
- (void)requestDidSucceed:(TJPlacement*)placement{
    if(placement.isContentAvailable == NO) {
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
        [Helper showAlertViewWithContext:self title:str_NVideo message:@"" style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
    }
    [placement showContentWithViewController:nil];
}
- (void)requestDidFail:(TJPlacement*)placement error:(NSError*)error{
    if(placement.isContentAvailable == NO) {
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
        [Helper showAlertViewWithContext:self title:str_NVideo message:@"" style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
    }
}
- (void)contentIsReady:(TJPlacement*)placement{
}
- (void)contentDidAppear:(TJPlacement*)placement{
}
- (void)contentDidDisappear:(TJPlacement*)placement{
    [[TapJoyManager sharedManager] getEarnedDeltaWithCompletion:^(int earnedCount) {
        [[UserManager sharedManager] increaseUserCoins:earnedCount onSuccess:^{
            [self getUserCoins];
            [Tapjoy showDefaultEarnedCurrencyAlert];
        } onFailure:^(NSError * error) {
            
        }];
        
    }];
}

- (void)videoAdBegan {
    
}
- (void)videoAdClosed {
    
}
- (void)videoAdCompleted {
    
}




#pragma mark UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.collectionView.frame.size.width - 20)/4, (self.collectionView.frame.size.width - 20)/4);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([self.userMediaPhotos count] < 5) {
        return [self.userMediaPhotos count];
    }else {
        return 4;
    }
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserPhotosCVC* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserPhotosCVC" forIndexPath:indexPath];
    [cell.mainImage sd_setImageWithURL:self.userMediaPhotos[indexPath.row]];
    return cell;
}

@end
