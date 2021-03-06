//
//  ChatSettingViewController.m
//  TeamsHit
//
//  Created by 仙林 on 16/8/18.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "ChatSettingViewController.h"
#import "FriendInformationModel.h"
#import "CreatGroupChatRoomViewController.h"
#import "FriendInformationViewController.h"

@interface ChatSettingViewController ()<UIActionSheetDelegate, TipViewDelegate>
{
    NSString *portraitUrl;
    NSString *nickname;
    BOOL enableNotification;
    RCConversation *currentConversation;
}
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *addGroupmenberView;
@property (strong, nonatomic) IBOutlet UILabel *remarkLabel;
@property (strong, nonatomic) IBOutlet UIButton *topChatbt;
@property (strong, nonatomic) IBOutlet UIButton *messageDisturbbt;
@property (strong, nonatomic) IBOutlet UIButton *findChatcontent;
@property (strong, nonatomic) IBOutlet UIButton *clearChatContentbt;

@end

@implementation ChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TeamHitBarButtonItem * leftBarItem = [TeamHitBarButtonItem leftButtonWithImage:[UIImage imageNamed:@"img_back"] title:@""];
    [leftBarItem addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarItem];
    
    self.title = @"聊天详情";
    
    UITapGestureRecognizer * addGroupFriendTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addGroupFriendAction:)];
    [self.addGroupmenberView addGestureRecognizer:addGroupFriendTap];
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.model.iconUrl] placeholderImage:[UIImage imageNamed:@"logo(1)"]];
    UITapGestureRecognizer * FrienddetailTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(FrienddetailTapAction:)];
    [self.iconImageView addGestureRecognizer:FrienddetailTap];
    
    
    self.remarkLabel.text = self.model.nickName;
    
    [self.messageDisturbbt setImage:[[UIImage imageNamed:@"forbid"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [self.messageDisturbbt setImage:[[UIImage imageNamed:@"noForbid"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    [self.topChatbt setImage:[[UIImage imageNamed:@"forbid"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    [self.topChatbt setImage:[[UIImage imageNamed:@"noForbid"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    [self startLoadView];
    
    if (currentConversation.isTop) {
        self.topChatbt.selected = YES;
    }else
    {
        self.topChatbt.selected = NO;
    }
    
    [self updataDataSource];
    
    // Do any additional setup after loading the view from its nib.
}
- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"1px.png"] forBarMetrics:UIBarMetricsDefault];
    if (self.model.displayName.length == 0) {
        self.remarkLabel.text = self.model.nickName;
    }else
    {
        self.remarkLabel.text = self.model.displayName;
    }
    
}

- (void)updataDataSource
{
    RCDUserInfo * userinfo = [[RCDataBaseManager shareInstance]getFriendInfo:[NSString stringWithFormat:@"%@", self.model.userId]];
    userinfo.name = self.model.nickName;
    userinfo.portraitUri = self.model.iconUrl;
    userinfo.displayName = self.model.displayName;
    [[RCDataBaseManager shareInstance]insertFriendToDB:userinfo];
    
    RCUserInfo * user = [[RCDataBaseManager shareInstance]getUserByUserId:[NSString stringWithFormat:@"%@", self.model.userId]];
    user.portraitUri = self.model.iconUrl;
    if (self.model.displayName.length != 0) {
        user.name = self.model.displayName;
    }else
    {
        user.name = self.model.nickName;
    }
    [[RCDataBaseManager shareInstance]insertUserToDB:user];
    [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:user.userId];
}

- (void)addGroupFriendAction:(UITapGestureRecognizer *)sender
{
    NSLog(@"增加好友创建讨论组");
    
    CreatGroupChatRoomViewController * crearGroupVc = [[CreatGroupChatRoomViewController alloc]init];
    crearGroupVc.targetId = [NSString stringWithFormat:@"%@", self.model.userId];
    [self.navigationController pushViewController:crearGroupVc animated:YES];
    
}
-(void)startLoadView
{
    __weak ChatSettingViewController *weakSelf = self;
    currentConversation = [[RCIMClient sharedRCIMClient] getConversation:ConversationType_PRIVATE
                                                                targetId:self.userId];
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_PRIVATE
                                                            targetId:self.userId
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                
                                                                 BOOL enableNotification = YES;
                                                                 if (nStatus == NOTIFY) {
                                                                     enableNotification = NO;
                                                                     NSLog(@"消息免打扰未开启");
                                                                 }else
                                                                 {
                                                                     NSLog(@"消息免打扰开启");
                                                                 }
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     weakSelf.messageDisturbbt.selected = enableNotification;
                                                                 });
                                                                 
//                                                                 if (nStatus == DO_NOT_DISTURB) {
//                                                                     NSLog(@"消息免打扰开启");
//                                                                     self.messageDisturbbt.selected = YES;
//                                                                 }else
//                                                                 {
//                                                                      NSLog(@"消息免打扰未开启");
//                                                                     self.messageDisturbbt.selected = NO;
//                                                                 }
                                                             }
                                                               error:^(RCErrorCode status){
                                                                   
                                                               }];
    
}

- (IBAction)topChatContentAction:(id)sender {
    
    BOOL success = [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_PRIVATE
                                               targetId:self.userId
                                                  isTop:!self.topChatbt.selected];
    if (success) {
        self.topChatbt.selected = !self.topChatbt.selected;
    }else
    {
        [self tipalert];
    }
    
}
- (IBAction)messageDisturbAction:(id)sender {
    __weak ChatSettingViewController *weakSelf = self;
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_PRIVATE
                                                            targetId:self.userId
                                                           isBlocked:!self.messageDisturbbt.selected
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     BOOL enableNotification = YES;
                                                                     
                                                                     if (nStatus == NOTIFY) {
                                                                         enableNotification = NO;
                                                                         NSLog(@"消息免打扰未开启");
                                                                     }else
                                                                     {
                                                                         NSLog(@"消息免打扰开启");
                                                                     }
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         weakSelf.messageDisturbbt.selected = enableNotification;
                                                                     });
                                                                     
                                                                     
//                                                                     if (nStatus == DO_NOT_DISTURB) {
//                                                                         NSLog(@"消息免打扰开启");
//                                                                         [self startLoadView];
//                                                                         self.messageDisturbbt.selected = YES;
//                                                                     }else
//                                                                     {
//                                                                         NSLog(@"消息免打扰未开启");
//                                                                         [self startLoadView];
//                                                                         self.messageDisturbbt.selected = NO;
//                                                                     }
                                                                 });
                                                                 
                                                             } error:^(RCErrorCode status) {
                                                                 NSLog(@"设置消息免打扰失败");
                                                             }];
    
}
- (IBAction)findChatContentAction:(id)sender {
}
- (IBAction)clearChatContentAction:(id)sender {
//    UIActionSheet *actionSheet =
//    [[UIActionSheet alloc] initWithTitle:@"确定清除聊天记录？"
//                                delegate:self
//                       cancelButtonTitle:@"取消"
//                  destructiveButtonTitle:@"确定"
//                       otherButtonTitles:nil];
//    
//    [actionSheet showInView:self.view];
//    actionSheet.tag = 100;
    
    TipView * tipView = [[TipView alloc]initWithFrame:[UIScreen mainScreen].bounds Message:[NSString stringWithFormat:@"确定清空和%@的聊天记录吗？", self.model.displayName] delete:NO];
    tipView.delegate = self;
    [tipView show];
    
}

- (void)complete
{
    BOOL  clearSuccess = [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:self.userId];
    if (clearSuccess) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"已清空" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearHistoryMsg" object:nil];
    }else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"清空失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
    }
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100)
    {
        if (buttonIndex == 0) {
            BOOL  clearSuccess = [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE targetId:self.userId];
            if (clearSuccess) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearHistoryMsg" object:nil];
            }else
            {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"清空失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
                [alert show];
            }
        }
    }
}

- (void)tipalert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"状态修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[RCIMClient sharedRCIMClient] getHistoryMessages:ConversationType_PRIVATE targetId:@"" oldestMessageId:999 count:10];
    
    // Dispose of any resources that can be recreated.
}

- (void)FrienddetailTapAction:(UITapGestureRecognizer *)sender
{
    __weak ChatSettingViewController * weakSelf = self;
    FriendInformationViewController * friend = [[FriendInformationViewController alloc]initWithNibName:@"FriendInformationViewController" bundle:nil];
    friend.targetId = self.userId;
    [friend changeDisplayname:^(NSString *displayName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.model.displayName = displayName;
        });
    }];
    
    [self.navigationController pushViewController:friend animated:YES];
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
