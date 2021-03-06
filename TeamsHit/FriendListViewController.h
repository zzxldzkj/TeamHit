//
//  FriendListViewController.h
//  TeamsHit
//
//  Created by 仙林 on 16/7/15.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *friendSearcgBar;
@property (strong, nonatomic) IBOutlet UITableView *friendsTabelView;

@property (nonatomic, strong)NSArray * keys;
@property (nonatomic, strong)NSMutableDictionary * allFriends;
@property (nonatomic, strong)NSArray * allKeys;// 好友列表首字母数组
@property (nonatomic, strong)NSArray * seleteUsers;

@end
