//
//  GroupListViewController.m
//  TeamsHit
//
//  Created by 仙林 on 16/9/8.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "GroupListViewController.h"
#import "SearcgGroupListCell.h"
#import "SearchGroupListModel.h"
#import "GameChatViewController.h"
#import "BragGameChatViewController.h"
#import "FantasyGameChatViewController.h"

#define CELL_IDENTIFIRE @"GroupCellIdentifire"

@interface GroupListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    MBProgressHUD* hud ;
}
@property (nonatomic, strong)NSMutableArray * dataSource;
@property (nonatomic, strong)NSMutableArray * bragArray;
@property (nonatomic, strong)NSMutableArray * fantasyArray;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray * keyArray;
@property (nonatomic, assign)BOOL isSyncGroup;
@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    TeamHitBarButtonItem * leftBarItem = [TeamHitBarButtonItem leftButtonWithImage:[UIImage imageNamed:@"img_back"] title:@""];
    self.title = @"房间";
    [leftBarItem addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarItem];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.hd_width, self.view.hd_height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SearcgGroupListCell" bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIRE];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1];

    self.dataSource = [NSMutableArray array];
    self.bragArray = [NSMutableArray array];
    self.fantasyArray = [NSMutableArray array];
    self.keyArray = [NSMutableArray array];
    
    [self getAllData];
//    [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {
//        
//    }];
    
}

- (void)dismissRefresh
{
    [self.tableView.mj_header endRefreshing];
}
- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar * bar = self.navigationController.navigationBar;
    [bar setShadowImage:[UIImage imageNamed:@"1px.png"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"1px.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)getAllData
{
    NSArray * alldataArr = [[RCDataBaseManager shareInstance]getAllGroup];
    
    if (alldataArr.count > 0) {
        
        for (RCDGroupInfo * groupInfo in alldataArr) {
            // 判断是否解散，没解散分类型
            if (groupInfo.isDismiss.intValue == 0) {
                if (groupInfo.GroupType == 1) {
                    [self.bragArray addObject:groupInfo];
                }else if (groupInfo.GroupType == 2)
                {
                    [self.fantasyArray addObject:groupInfo];
                }
            }
        }
    }
    if (self.bragArray.count != 0) {
        [self.dataSource addObject:self.bragArray];
        [self.keyArray addObject:@"吹牛"];
    }
    if (self.fantasyArray.count != 0) {
        [self.dataSource addObject:self.fantasyArray];
        [self.keyArray addObject:@"梦幻"];
    }
    if ([alldataArr count] == 0 && _isSyncGroup == NO) {
        
        [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {
                _isSyncGroup = YES;
                [self getAllData];
            
        }];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.bragArray.count;
    }else
    {
        return self.fantasyArray.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.keyArray[section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearcgGroupListCell * cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIRE];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.iconImageView.layer.masksToBounds = YES;
    
    RCDGroupInfo * groupInfo = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.model = groupInfo;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RCDGroupInfo * group = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    RCGroup * groupInfo = [[RCGroup alloc]init];
    groupInfo.groupId = group.groupId;
    groupInfo.groupName = group.groupName;
    groupInfo.portraitUri = group.portraitUri;
    [[RCIM sharedRCIM]refreshGroupInfoCache:groupInfo withGroupId:groupInfo.groupId];
    
    if (group.GroupType == 1) {
        [self pushBragGameView:group];
    }else if (group.GroupType == 2)
    {
        [self pushFantasyGameView:group];
    }
    
}

- (void)pushBragGameView:(RCDGroupInfo *)group
{
    BragGameChatViewController * conversationVC = [[BragGameChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_GROUP;
    conversationVC.targetId = group.groupId;
    //    _conversationVC.userName = group.groupName;
    conversationVC.title = group.groupName;
    //    _conversationVC.conversation = model;
    //    _conversationVC.unReadMessage = model.unreadMessageCount;
    conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
    conversationVC.enableUnreadMessageIcon=YES;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (void)pushFantasyGameView:(RCDGroupInfo *)group
{
    FantasyGameChatViewController * conversationVC = [[FantasyGameChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_GROUP;
    conversationVC.targetId = group.groupId;
    //    _conversationVC.userName = group.groupName;
    conversationVC.title = group.groupName;
    //    _conversationVC.conversation = model;
    //    _conversationVC.unReadMessage = model.unreadMessageCount;
    conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
    conversationVC.enableUnreadMessageIcon=YES;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
