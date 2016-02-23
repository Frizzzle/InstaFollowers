//
//  SetupCategoriesVC.m
//  5000Followers
//
//  Created by Koctya on 11/30/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "SetupCategoriesVC.h"
#import "ChangeCategories.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "Helper.h"
#import "Managers.h"

@interface SetupCategoriesVC ()
@property (weak, nonatomic) IBOutlet UIButton *ownButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property NSArray* categories;
@property NSMutableArray* ownCategories;
@property NSMutableArray* searchCategories;
@property (weak, nonatomic) IBOutlet UITableView *searchTV;
@property BOOL isOwnChangeCategory;
@property MBProgressHUD* progressBar;

@end

@implementation SetupCategoriesVC
-(void) viewDidLoad {
    [super viewDidLoad];
    [Helper changeBackgroundWithContext:self];
    [self.ownButton.layer setBackgroundColor:[BUTTON_BLUE CGColor]];
    [self.searchButton.layer setBackgroundColor:[BUTTON_BLUE CGColor]];
    
    self.isOwnChangeCategory = YES;
    self.ownCategories = [[NSMutableArray alloc] init];
    self.searchCategories = [[NSMutableArray alloc] init];
    [self loadCategoryFromParse];
    if(self.fromMain) {
        [self.navigationItem setHidesBackButton:YES];
    }
    
}

-(void)selectedCategory:(NSArray *)categories {
    if(self.isOwnChangeCategory == YES){
        self.ownCategories = [[NSMutableArray alloc] initWithArray: categories];
    }else {
        self.searchCategories = [[NSMutableArray alloc] initWithArray: categories ];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden: YES animated:YES];
}

-(void)loadCategoryFromParse {
    
    self.progressBar = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressBar.labelText = str_Loading;
    [[CategoryManager sharedManager] getAllCategoriesOnLoad:^(NSMutableArray * categories) {
        self.categories = categories;
        [[CategoryManager sharedManager] getOwnCategoriesOnLoad:^(NSMutableArray * ownCategories) {
            self.ownCategories = [[NSMutableArray alloc] initWithArray:ownCategories];
            [[CategoryManager sharedManager] getSearchCategoriesOnLoad:^(NSMutableArray * searchCategories) {
                self.searchCategories = [[NSMutableArray alloc] initWithArray:searchCategories];
                [self.progressBar hide:YES];
            }];
        }];
    }];
}
- (IBAction)finishAction:(id)sender {
    if((self.ownCategories.count == 0) || (self.searchCategories.count == 0)) {
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
        [Helper showAlertViewWithContext:self title:str_Wrong_category message:str_PCC style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
        return;
    }
    self.progressBar = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressBar.labelText = str_UCategory;
    [[CategoryManager sharedManager] updateCategoriesOwn:self.ownCategories search:self.searchCategories onFinish:^{
        if (self.fromMain == YES) {
            [self.progressBar hide:YES];
            [[FollowersManager sharedManager] loadFollowers];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [self performSegueWithIdentifier:SEGUE_MAIN sender:self];
        }

    }];
    
}

- (IBAction)selectOwnCategory:(id)sender {
    self.isOwnChangeCategory = YES;
    [self performSegueWithIdentifier:SEGUE_SET_CATEGORIES sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: SEGUE_SET_CATEGORIES]) {
        UINavigationController* nc = [segue destinationViewController];
        ChangeCategories* vc = [[nc viewControllers] firstObject];
        vc.categories = [[NSMutableArray alloc ] initWithArray:self.categories] ;
        vc.delegate = self;
        if(self.isOwnChangeCategory == YES) {
            vc.selectedCategories = self.ownCategories;
        }else {
            vc.selectedCategories = self.searchCategories;
        }
    }
}

- (IBAction)selectSearchCategory:(id)sender {
    self.isOwnChangeCategory = NO;
    [self performSegueWithIdentifier:SEGUE_SET_CATEGORIES sender:self];
}

#pragma mark UITableView 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = self.categories[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}


@end
