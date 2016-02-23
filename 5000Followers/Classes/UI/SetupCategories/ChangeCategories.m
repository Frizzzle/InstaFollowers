//
//  ChangeCategories.m
//  5000Followers
//
//  Created by Koctya on 12/1/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import "ChangeCategories.h"
#import "SetCategoriesTVC.h"
#import "Helper.h"
#import "Constants.h"


@interface ChangeCategories ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property BOOL allCategory;

@end

@implementation ChangeCategories

- (void)selectedCategory:(NSArray *)categories {
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [Helper changeBackgroundWithContext:self];
    self.allCategory = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:str_Done
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [self.categories insertObject:str_All_Topics atIndex:0];
    
}

-(IBAction)doneAction {
    if(self.selectedCategories.count == 0) {
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:str_OK style:UIAlertActionStyleDefault handler:nil];
        [Helper showAlertViewWithContext:self title:str_Wrong_category message:str_PCC style:UIAlertControllerStyleAlert actions:[[NSMutableArray alloc] initWithObjects:okAction, nil]];
        return;
    }
    [self.categories removeObjectAtIndex:0];
    [self.delegate selectedCategory:self.selectedCategories];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SetCategoriesTVC* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(indexPath.row == 0) {
        [self.selectedCategories removeAllObjects];
        for (NSString* item in self.categories) {
            if(![item  isEqual: str_All_Topics]) {
               [self.selectedCategories addObject:item];
            }
        }
        [self.tableView reloadData];
        cell.categorySelectImage.hidden = NO;
    }else {
        if(cell.categorySelectImage.hidden == NO) {
            cell.categorySelectImage.hidden = YES;
            [self.selectedCategories removeObject:self.categories[indexPath.row]];
        }else {
            cell.categorySelectImage.hidden = NO;
            [self.selectedCategories addObject:self.categories[indexPath.row]];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SetCategoriesTVC* cell = [tableView dequeueReusableCellWithIdentifier:@"SetCategoriesTVC"];

    cell.categoryName.text = self.categories[indexPath.row];

        if ([self.selectedCategories containsObject:self.categories[indexPath.row]]) {
            cell.categorySelectImage.hidden = NO;
        }else {
            cell.categorySelectImage.hidden = YES;
        }
    
    
    return cell;
}

@end
