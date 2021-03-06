//
//  ChatListCollectionViewController.m
//  TeamsHit
//
//  Created by 仙林 on 16/10/26.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "ChatListCollectionViewController.h"
#import "KxMenu.h"
#import "SearchFriendViewController.h"
#import "UIColor+RCColor.h"
#import "ChatViewController.h"
#import "RCDChatListCell.h"
#import "RCDHttpTool.h"
#import "GameChatViewController.h"
#import "FriendListViewController.h"
#import "CreatGroupChatRoomViewController.h"
#import "AddEquipmentViewController.h"

#import "BragGameChatViewController.h"
@interface ChatListCollectionViewController ()
@property (nonatomic,strong) RCConversationModel *tempModel;
@property (nonatomic,assign) BOOL isClick;
- (void) updateBadgeValueForTabBarItem;
@end


@implementation ChatListCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    TeamHitBarButtonItem * leftBarItem = [TeamHitBarButtonItem leftButtonWithImage:[UIImage imageNamed:@"img_back"] title:@""];
    [leftBarItem addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarItem];
    
    self.conversationListTableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    self.conversationListTableView.tableFooterView = [UIView new];
    
    self.showConnectingStatusOnNavigatorBar = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshUIWithNotification) name:@"deleteFriendNotification" object:nil];
    
    // Do any additional setup after loading the view.
}
- (void)refreshUIWithNotification
{
    NSLog(@"删除好友了");
    [self refreshConversationTableViewIfNeeded];
}
- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"1px.png"] forBarMetrics:UIBarMetricsDefault];
    _isClick = YES;
    [self notifyUpdateUnreadMessageCount];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(receiveNeedRefreshNotification:)
                                                name:@"kRCNeedReloadDiscussionListNotification"
                                              object:nil];
    
    
    RCUserInfo *groupNotify = [[RCUserInfo alloc] initWithUserId:[RCIM sharedRCIM].currentUserInfo.userId
                                                            name:[RCIM sharedRCIM].currentUserInfo.name
                                                        portrait:[RCIM sharedRCIM].currentUserInfo.portraitUri];
    [[RCIM sharedRCIM] refreshUserInfoCache:groupNotify withUserId:[RCIM sharedRCIM].currentUserInfo.userId];
    //由于当天的消息会被补偿回来，导致如果重装了应用，当天退出的群组会出现在会话列表。判断群组通知消息的操作如果是退出群组，就直接从会话列表中删除。
    NSArray *conversationListArray = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)]];
    for (RCConversation *conversation in conversationListArray){
        if ([conversation.lastestMessage isKindOfClass:[RCGroupNotificationMessage class]])
        {
            RCGroupNotificationMessage *groupNotification = (RCGroupNotificationMessage*)conversation.lastestMessage;
            if ([groupNotification.operation isEqualToString:@"Quit"]) {
                NSData *jsonData = [groupNotification.data dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *data = [dictionary[@"data"] isKindOfClass:[NSDictionary class]]? dictionary[@"data"]: nil;
                NSString *nickName = [data[@"operatorNickname"] isKindOfClass:[NSString class]]? data[@"operatorNickname"]: nil;
                if ([nickName isEqualToString:[RCIM sharedRCIM].currentUserInfo.name]) {
                    [[RCIMClient sharedRCIMClient] removeConversation:conversation.conversationType targetId:conversation.targetId];
                    [self refreshConversationTableViewIfNeeded];
                }
                
            }
        }
    }
    [self refreshConversationTableViewIfNeeded];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"kRCNeedReloadDiscussionListNotification"
                                                  object:nil];
}


- (void)updateBadgeValueForTabBarItem
{
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient]getUnreadCount:self.displayConversationTypeArray];
        if (count>0) {
            __weakSelf.tabBarItem.badgeValue = [[NSString alloc]initWithFormat:@"%d",count];
        }else
        {
            __weakSelf.tabBarItem.badgeValue = nil;
        }
        
    });
}

/**
 *  点击进入会话界面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"点击了cell");
    
    if (_isClick) {
        _isClick = NO;
        
        if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
            
            if (model.conversationType == 3) {
                BragGameChatViewController * _conversationVC = [[BragGameChatViewController alloc]init];
                _conversationVC.conversationType = model.conversationType;
                _conversationVC.targetId = model.targetId;
                _conversationVC.userName = model.conversationTitle;
                _conversationVC.title = model.conversationTitle;
                _conversationVC.conversation = model;
                _conversationVC.unReadMessage = model.unreadMessageCount;
                _conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
                _conversationVC.enableUnreadMessageIcon=YES;
                _conversationVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:_conversationVC animated:YES];
            }else
            {
                ChatViewController *_conversationVC = [[ChatViewController alloc]init];
                _conversationVC.conversationType = model.conversationType;
                _conversationVC.targetId = model.targetId;
                _conversationVC.userName = model.conversationTitle;
                _conversationVC.title = model.conversationTitle;
                _conversationVC.conversation = model;
                _conversationVC.unReadMessage = model.unreadMessageCount;
                _conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
                _conversationVC.enableUnreadMessageIcon=YES;
                
                if (model.conversationType == ConversationType_SYSTEM) {
                    _conversationVC.userName = @"系统消息";
                    _conversationVC.title = @"系统消息";
                }
                if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    //                RCDAddressBookViewController *addressBookVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RCDAddressBookViewController"];
                    //                addressBookVC.needSyncFriendList = YES;
                    //                [self.navigationController pushViewController:addressBookVC animated:YES];
                    return;
                }
                //如果是单聊，不显示发送方昵称
                if (model.conversationType == ConversationType_PRIVATE) {
                    _conversationVC.displayUserNameInCell = NO;
                }
                _conversationVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:_conversationVC animated:YES];
            }
            
            
            
        }
    }

}
//*********************插入自定义Cell*********************//

//插入自定义会话model
-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource
{
    
    for (int i=0; i<dataSource.count; i++) {
        RCConversationModel *model = dataSource[i];
        //筛选请求添加好友的系统消息，用于生成自定义会话类型的cell
        if(model.conversationType == ConversationType_SYSTEM && [model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]])
        {
            model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
        }
        if ([model.lastestMessage isKindOfClass:[RCGroupNotificationMessage class]])
        {
            RCGroupNotificationMessage *groupNotification = (RCGroupNotificationMessage*)model.lastestMessage;
            if ([groupNotification.operation isEqualToString:@"Quit"]) {
                NSData *jsonData = [groupNotification.data dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *data = [dictionary[@"data"] isKindOfClass:[NSDictionary class]]? dictionary[@"data"]: nil;
                NSString *nickName = [data[@"operatorNickname"] isKindOfClass:[NSString class]]? data[@"operatorNickname"]: nil;
                if ([nickName isEqualToString:[RCIM sharedRCIM].currentUserInfo.name]) {
                    [[RCIMClient sharedRCIMClient] removeConversation:model.conversationType targetId:model.targetId];
                    [self refreshConversationTableViewIfNeeded];
                }
                
            }
        }
    }
//    NSLog(@"dataSource = %d", dataSource.count);
    return dataSource;
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell
                             atIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel * model = self.conversationListDataSource[indexPath.row];
    if (model.conversationType == ConversationType_PRIVATE) {
        RCConversationCell * cell1 = (RCConversationCell *)cell;
        //        cell1.conversationTitle.textColor = [UIColor redColor];
    }
}

//左滑删除
-(void)rcConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //可以从数据库删除数据
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_SYSTEM targetId:model.targetId];
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    [self.conversationListTableView reloadData];
}

//高度
-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0f;
}

//自定义cell
-(RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    
    __block NSString *userName    = nil;
    __block NSString *portraitUri = nil;
    
    __weak ChatListCollectionViewController *weakSelf = self;
    //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
    if (nil == model.extend) {
        // Not finished yet, To Be Continue...
        if(model.conversationType == ConversationType_SYSTEM && [model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]])
        {
            RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)model.lastestMessage;
            if (_contactNotificationMsg.sourceUserId == nil) {
                RCDChatListCell *cell = [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
                cell.lblDetail.text = @"好友请求";
                [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri] placeholderImage:[UIImage imageNamed:@"system_notice"]];
                return cell;
                
            }
            NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:_contactNotificationMsg.sourceUserId];
            if (_cache_userinfo) {
                userName = _cache_userinfo[@"username"];
                portraitUri = _cache_userinfo[@"portraitUri"];
            } else {
                NSDictionary *emptyDic = @{};
                [[NSUserDefaults standardUserDefaults]setObject:emptyDic forKey:_contactNotificationMsg.sourceUserId];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [RCDHTTPTOOL getUserInfoByUserID:_contactNotificationMsg.sourceUserId
                                      completion:^(RCUserInfo *user) {
                                          if (user == nil) {
                                              return;
                                          }
                                          RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
                                          rcduserinfo_.name = user.name;
                                          rcduserinfo_.userId = user.userId;
                                          rcduserinfo_.portraitUri = user.portraitUri;
                                          
                                          model.extend = rcduserinfo_;
                                          
                                          //local cache for userInfo
                                          NSDictionary *userinfoDic = @{@"username": rcduserinfo_.name,
                                                                        @"portraitUri":rcduserinfo_.portraitUri
                                                                        };
                                          [[NSUserDefaults standardUserDefaults]setObject:userinfoDic forKey:_contactNotificationMsg.sourceUserId];
                                          [[NSUserDefaults standardUserDefaults]synchronize];
                                          
                                          [weakSelf.conversationListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                      }];
            }
        }
        
    }else{
        RCDUserInfo *user = (RCDUserInfo *)model.extend;
        userName    = user.name;
        portraitUri = user.portraitUri;
    }
    
    RCDChatListCell *cell = [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.lblDetail.text =[NSString stringWithFormat:@"来自%@的好友请求",userName];
    [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri] placeholderImage:[UIImage imageNamed:@"system_notice"]];
    cell.labelTime.text = [self ConvertMessageTime:model.sentTime / 1000];
    cell.model = model;
    return cell;
}

#pragma mark - private
- (NSString *)ConvertMessageTime:(long long)secs {
    NSString *timeText = nil;
    
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:secs];
    
    //    DebugLog(@"messageDate==>%@",messageDate);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strMsgDay = [formatter stringFromDate:messageDate];
    
    NSDate *now = [NSDate date];
    NSString *strToday = [formatter stringFromDate:now];
    NSDate *yesterday = [[NSDate alloc] initWithTimeIntervalSinceNow:-(24 * 60 * 60)];
    NSString *strYesterday = [formatter stringFromDate:yesterday];
    
    NSString *_yesterday = nil;
    if ([strMsgDay isEqualToString:strToday]) {
        [formatter setDateFormat:@"HH':'mm"];
    } else if ([strMsgDay isEqualToString:strYesterday]) {
        _yesterday = NSLocalizedStringFromTable(@"Yesterday", @"RongCloudKit", nil);
        //[formatter setDateFormat:@"HH:mm"];
    }
    
    if (nil != _yesterday) {
        timeText = _yesterday; //[_yesterday stringByAppendingFormat:@" %@", timeText];
    } else {
        timeText = [formatter stringFromDate:messageDate];
    }
    
    return timeText;
}

//*********************插入自定义Cell*********************//


#pragma mark - 收到消息监听

-(void)didReceiveMessageNotification:(NSNotification *)notification
{
    __weak typeof(&*self) blockSelf_ = self;
    //处理好友请求
    RCMessage *message = notification.object;
    if ([message.content isMemberOfClass:[RCContactNotificationMessage class]]) {
        
        if (message.conversationType != ConversationType_SYSTEM) {
            NSLog(@"好友消息要发系统消息！！！");
#if DEBUG
            @throw  [[NSException alloc] initWithName:@"error" reason:@"好友消息要发系统消息！！！" userInfo:nil];
#endif
        }
        RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)message.content;
        if (_contactNotificationMsg.sourceUserId == nil || _contactNotificationMsg.sourceUserId .length ==0) {
            return;
        }
        //该接口需要替换为从消息体获取好友请求的用户信息
        [RCDHTTPTOOL getUserInfoByUserID:_contactNotificationMsg.sourceUserId
                              completion:^(RCUserInfo *user) {
                                  RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
                                  rcduserinfo_.name = user.name;
                                  rcduserinfo_.userId = user.userId;
                                  rcduserinfo_.portraitUri = user.portraitUri;
                                  
                                  RCConversationModel *customModel = [RCConversationModel new];
                                  customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
                                  customModel.extend = rcduserinfo_;
                                  customModel.senderUserId = message.senderUserId;
                                  customModel.lastestMessage = _contactNotificationMsg;
                                  //[_myDataSource insertObject:customModel atIndex:0];
                                  
                                  //local cache for userInfo
                                  NSDictionary *userinfoDic = @{@"username": rcduserinfo_.name,
                                                                @"portraitUri":rcduserinfo_.portraitUri
                                                                };
                                  [[NSUserDefaults standardUserDefaults]setObject:userinfoDic forKey:_contactNotificationMsg.sourceUserId];
                                  [[NSUserDefaults standardUserDefaults]synchronize];
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      //调用父类刷新未读消息数
                                      [blockSelf_ refreshConversationTableViewWithConversationModel:customModel];
                                      //[super didReceiveMessageNotification:notification];
                                      //              [blockSelf_ resetConversationListBackgroundViewIfNeeded];
                                      [self notifyUpdateUnreadMessageCount];
                                      
                                      //当消息为RCContactNotificationMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表。
                                      //原因请查看super didReceiveMessageNotification的注释。
                                      NSNumber *left = [notification.userInfo objectForKey:@"left"];
                                      if (0 == left.integerValue) {
                                          [super refreshConversationTableViewIfNeeded];
                                      }
                                  });
                              }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //调用父类刷新未读消息数
            NSLog(@"[message.content class] = %@", [message.content class]);
            [super didReceiveMessageNotification:notification];
            //                        [self notifyUpdateUnreadMessageCount]; //super会调用notifyUpdateUnreadMessageCount
            [blockSelf_ refreshConversationTableViewIfNeeded];
            //            [RCDHTTPTOOL getUserInfoByUserID:message.senderUserId
            //                                  completion:^(RCUserInfo *user) {
            //                                      RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
            //                                      rcduserinfo_.name = user.name;
            //                                      rcduserinfo_.userId = user.userId;
            //                                      rcduserinfo_.portraitUri = user.portraitUri;
            //
            //                                      RCConversationModel *customModel = [RCConversationModel new];
            //                                      customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
            //                                      customModel.extend = rcduserinfo_;
            //                                      customModel.senderUserId = message.senderUserId;
            //                                      customModel.lastestMessage = message.content;
            //                                      //[_myDataSource insertObject:customModel atIndex:0];
            //
            //                                      dispatch_async(dispatch_get_main_queue(), ^{
            //                                          //调用父类刷新未读消息数
            //                                          [blockSelf_ refreshConversationTableViewWithConversationModel:customModel];
            //                                          //[super didReceiveMessageNotification:notification];
            //                                          //              [blockSelf_ resetConversationListBackgroundViewIfNeeded];
            //                                          [self notifyUpdateUnreadMessageCount];
            //
            //                                          //当消息为RCContactNotificationMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表。
            //                                          //原因请查看super didReceiveMessageNotification的注释。
            //                                          NSNumber *left = [notification.userInfo objectForKey:@"left"];
            //                                          if (0 == left.integerValue) {
            //                                              [super refreshConversationTableViewIfNeeded];
            //                                          }
            //                                      });
            //                                  }];
        });
    }
}
-(void)didTapCellPortrait:(RCConversationModel *)model
{
    NSLog(@"点击了cell头部");
    
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        
        
        if (model.conversationType == 3) {
            BragGameChatViewController * _conversationVC = [[BragGameChatViewController alloc]init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.userName = model.conversationTitle;
            _conversationVC.title = model.conversationTitle;
            _conversationVC.conversation = model;
            _conversationVC.unReadMessage = model.unreadMessageCount;
            _conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
            _conversationVC.enableUnreadMessageIcon=YES;
            _conversationVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:_conversationVC animated:YES];
        }else
        {
            ChatViewController *_conversationVC = [[ChatViewController alloc]init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.userName = model.conversationTitle;
            _conversationVC.title = model.conversationTitle;
            _conversationVC.conversation = model;
            _conversationVC.unReadMessage = model.unreadMessageCount;
            _conversationVC.enableNewComingMessageIcon=YES;//开启消息提醒
            _conversationVC.enableUnreadMessageIcon=YES;
            if (model.conversationType == ConversationType_SYSTEM) {
                _conversationVC.userName = @"系统消息";
                _conversationVC.title = @"系统消息";
            }
            if ([model.objectName isEqualToString:@"RC:ContactNtf"]) {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                //            RCDAddressBookViewController *addressBookVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RCDAddressBookViewController"];
                //            addressBookVC.needSyncFriendList = YES;
                //            [self.navigationController pushViewController:addressBookVC animated:YES];
                return;
            }
            _conversationVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:_conversationVC animated:YES];
            
        }
        
    }
    
    
}



- (void)notifyUpdateUnreadMessageCount
{
    [self updateBadgeValueForTabBarItem];
}

- (void)receiveNeedRefreshNotification:(NSNotification *)status {
    __weak typeof(&*self) __blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (__blockSelf.displayConversationTypeArray.count == 1 && [self.displayConversationTypeArray[0] integerValue]== ConversationType_DISCUSSION) {
            [__blockSelf refreshConversationTableViewIfNeeded];
        }
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //    [[RCIMClient sharedRCIMClient]removeConversation:ConversationType_PRIVATE targetId:@""];
    
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
