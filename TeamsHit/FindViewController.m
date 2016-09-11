//
//  FindViewController.m
//  TeamsHit
//
//  Created by 仙林 on 16/7/15.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "FindViewController.h"
#import "WXViewController.h"

@interface FindViewController ()
@property (strong, nonatomic) IBOutlet UIView *friendCircle;
@property (strong, nonatomic) IBOutlet UILabel *noreadMassageNumberLabel;

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TeamHitBarButtonItem * leftBarItem = [TeamHitBarButtonItem leftButtonWithImage:[UIImage imageNamed:@"navigationlogo"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarItem];
    
    UITapGestureRecognizer * friendCircleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(friendCircleTapAction:)];
    [self.friendCircle addGestureRecognizer:friendCircleTap];
    
    self.noreadMassageNumberLabel.layer.cornerRadius = 8;
    self.noreadMassageNumberLabel.layer.masksToBounds = YES;
    self.noreadMassageNumberLabel.text = @"";
    self.noreadMassageNumberLabel.adjustsFontSizeToFitWidth = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateFriendCircleMessageCount:) name:@"UpdateFriendCircleMessageCount" object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)updateFriendCircleMessageCount:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.noreadMassageNumberLabel.hidden) {
            self.noreadMassageNumberLabel.hidden = NO;
        }
        NSLog(@"[[RCDataBaseManager shareInstance]getFriendcircleMessageNumber] = %d", [[RCDataBaseManager shareInstance]getFriendcircleMessageNumber]);
        self.noreadMassageNumberLabel.text = [NSString stringWithFormat:@"%d", [[RCDataBaseManager shareInstance]getFriendcircleMessageNumber]];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar * bar = self.navigationController.navigationBar;
    [bar setShadowImage:[UIImage imageNamed:@"1px.png"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"1px.png"] forBarMetrics:UIBarMetricsDefault];
    
    if ([[RCDataBaseManager shareInstance]getFriendcircleMessageNumber]) {
        self.noreadMassageNumberLabel.hidden = NO;
        self.noreadMassageNumberLabel.text = [NSString stringWithFormat:@"%d", [[RCDataBaseManager shareInstance]getFriendcircleMessageNumber]];
    }else{
        self.noreadMassageNumberLabel.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)friendCircleTapAction:(UITapGestureRecognizer *)sender
{
    NSLog(@"朋友圈界面");
    WXViewController * wxVC = [[WXViewController alloc]init];
    wxVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wxVC animated:YES];
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
