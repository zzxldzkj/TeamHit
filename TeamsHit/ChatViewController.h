//
//  ChatViewController.h
//  TeamsHit
//
//  Created by 仙林 on 16/8/11.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface ChatViewController : RCConversationViewController

/**
 *  会话数据模型
 */
@property (strong,nonatomic) RCConversationModel *conversation;

@property BOOL needPopToRootView;

@end
