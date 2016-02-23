//
//  GetFollowersTVC.h
//  5000Followers
//
//  Created by Koctya on 11/23/15.
//  Copyright © 2015 Pro.Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTImageButton/JTImageButton.h>

@interface GetFollowersTVC : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *countFollowers;
@property (weak, nonatomic) IBOutlet JTImageButton *getFollowersBtn;
@property (weak, nonatomic) IBOutlet UILabel *coinsCountLbl;

@end
