//
//  LoginViewController.m
//  TeamsHit
//
//  Created by 仙林 on 16/7/12.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "RCDUtilities.h"
#import "MyTabBarController.h"
#import "CompleteInformationViewController.h"
#import "ForgetPAsswordViewController.h"


@interface LoginViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
{
    MBProgressHUD* hud ;
}

@property (strong, nonatomic) IBOutlet UIView *backGroundView;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UITextField *accountNumber;
@property (strong, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UIButton *hiddenPasswordBT;
@property (strong, nonatomic) IBOutlet UIButton *loginBT;
@property (nonatomic, strong)UITextField * myTextfiled;

@property (nonatomic, strong)NSTimer * overTimer;
@property (nonatomic, assign)BOOL noOverTime;
@property (nonatomic, strong)NSTimer * timer;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.accountNumber.returnKeyType = UIReturnKeyDone;
    self.passwordTF.returnKeyType = UIReturnKeyDone;
    self.passwordTF.secureTextEntry = YES;
    
    [self.hiddenPasswordBT setImage:[[UIImage imageNamed:@"password_hide.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.hiddenPasswordBT setImage:[[UIImage imageNamed:@"password_show.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    
    self.loginBT.layer.cornerRadius = 3;
    self.loginBT.layer.masksToBounds = YES;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
    [self.view addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                             object:nil];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    UINavigationBar * bar = self.navigationController.navigationBar;
    [bar setShadowImage:[UIImage imageNamed:@"1px.png"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"1px.png"] forBarMetrics:UIBarMetricsDefault];
    self.noOverTime = NO;
    // 自动登录
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AccountNumber"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"]) {
        self.accountNumber.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"AccountNumber"];
        self.passwordTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"haveLogin"] boolValue]) {
            [self login];
        }else
        {
            self.passwordTF.text = @"";
        }
    }
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    UINavigationBar * bar = self.navigationController.navigationBar;
    [bar setShadowImage:nil];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}
#pragma mark - 键盘监听事件
- (void)keyboardWillShow:(NSNotification *)note
{
//    NSDictionary * info = [note userInfo];
//    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    CGFloat offY = (self.view.hd_height-keyboardSize.height)-self.myTextfiled.hd_y - self.myTextfiled.hd_height - 10;//屏幕总高度-键盘高度-UITextField高度
//    CGRect inputFieldRect = self.backGroundView.frame;
//    inputFieldRect.origin.y += offY;
//    
//    CGRect begin = [[[note userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
//    
//    CGRect end = [[[note userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
//    
//    //因为第三方键盘或者是在键盘加个toolbar会导致回调三次，这个判断用来判断是否是第三次回调，原生只有一次
//    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
//        
//        //处理逻辑
//        [UIView beginAnimations:nil context:NULL];//此处添加动画，使之变化平滑一点
//        [UIView setAnimationDuration:0.3];//设置动画时间 秒为单位
//        self.backGroundView.frame = inputFieldRect;//UITextField位置的y坐标移动到offY
//        [UIView commitAnimations];//开始动画效果
//    }
    
}
-(void)keyboardWillHide:(NSNotification *)note{
//    [UIView beginAnimations:nil context:NULL];//此处添加动画，使之变化平滑一点
//    [UIView setAnimationDuration:0.3];
//    self.backGroundView.frame = CGRectMake(0, 0, self.view.hd_width, self.view.hd_height);//UITextField位置复原
//    
//    [UIView commitAnimations];
}

#pragma mark - textfiledDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.myTextfiled = textField;
    self.backGroundView.frame = CGRectMake(0, 0, self.view.hd_width, self.view.hd_height);
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];//关闭键盘
    return YES;
}

- (void)tapGestureAction
{
    [self.accountNumber resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)hiddenPasswordAction:(id)sender {
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    if (((UIButton *)sender).selected) {
        self.passwordTF.secureTextEntry = NO;
        self.passwordTF.text = self.passwordTF.text;
    }else
    {
        self.passwordTF.secureTextEntry = YES;
        self.passwordTF.text = self.passwordTF.text;
    }
}
- (IBAction)loginAction:(id)sender {
    
    if (self.accountNumber.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入账号" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [alert performSelector:@selector(dismissAnimated:) withObject:nil afterDelay:1.5];
    }else if (self.passwordTF.text.length == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入密码" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [alert performSelector:@selector(dismissAnimated:) withObject:nil afterDelay:1.5];
    }else
    {
        
        [self login];
        
    }
    
}

- (void)login
{
    
    self.overTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timeOver) userInfo:nil repeats:NO];
    
    NSDictionary * jsonDic = @{
                               @"Account":self.accountNumber.text,
                               @"Password":self.passwordTF.text,
                               };
    hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"登录中...";
    [hud show:YES];
    __weak LoginViewController * weakself= self;
    [[HDNetworking sharedHDNetworking] POST:@"user/login" parameters:jsonDic progress:^(NSProgress * _Nullable progress) {
        ;
    } success:^(id  _Nonnull responseObject) {
        
        NSLog(@"**%@", responseObject);
        
        if ([[responseObject objectForKey:@"Code"] intValue] != 200) {
            [hud hide:YES];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:@"Message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert show];
            [alert performSelector:@selector(dismissAnimated:) withObject:nil afterDelay:1.2];
        }else
        {
            if (!weakself.noOverTime) {
                [UserInfo shareUserInfo].userToken = [responseObject objectForKey:@"UserToken"];
                [UserInfo shareUserInfo].rongToken = [responseObject objectForKey:@"RongToken"];
                
                
                RCUserInfo *user = [RCUserInfo new];
                user.userId = [NSString stringWithFormat:@"%@", responseObject[@"UserId"]];
                //            user.name = [NSString stringWithFormat:@"name%@", [NSString stringWithFormat:@"%@", responseObject[@"UserId"]]];
                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                [RCIM sharedRCIM].currentUserInfo = user;
                
                [hud hide:YES];
                // 连接融云服务器
                [[RCIM sharedRCIM] connectWithToken:[UserInfo shareUserInfo].rongToken success:^(NSString *userId) {
                    NSLog(@"连接融云成功");
                    
                } error:^(RCConnectErrorCode status) {
                    [hud hide:YES];
                    NSLog(@"连接融云失败");
                } tokenIncorrect:^{
                    [hud hide:YES];
                    NSLog(@"IncorrectToken");
                    
                    [weakself getRongToken];
                    
                }];
                [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"haveLogin"];
                // 账号密码保存到本地
                [[NSUserDefaults standardUserDefaults] setObject:self.accountNumber.text forKey:@"AccountNumber"];
                [[NSUserDefaults standardUserDefaults] setObject:self.passwordTF.text forKey:@"Password"];
                int i = 1;
                while (i) {
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AccountNumber"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"] ) {
                        i = 0;
                    }else
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:self.accountNumber.text forKey:@"AccountNumber"];
                        [[NSUserDefaults standardUserDefaults] setObject:self.passwordTF.text forKey:@"Password"];
                        
                    }
                }
                
                // 同步好友列表
                NSString * url = [NSString stringWithFormat:@"%@userinfo/getFriendList?token=%@", POST_URL, [UserInfo shareUserInfo].userToken];
                [RCDDataSource syncFriendList:url complete:^(NSMutableArray *friends) {}];
                
                // 同步组群
                [RCDDataSource syncGroups];
                
                if ([[responseObject objectForKey:@"IsCompleteInfor"] intValue ] == 1) {
                    [RCDHTTPTOOL refreshUserInfoByUserID:[NSString stringWithFormat:@"%@", responseObject[@"UserId"]]];
                    [weakself pushMyTabbarViewController];
                }else
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先完善用户信息" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alert show];
                    
                }
                weakself.noOverTime = YES;
            }
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [hud hide:YES];
        [weakself cancelTime];
        NSLog(@"error = %@", error);
    }];
}

- (void)timeOver
{
    if (self.noOverTime) {
    }else
    {
        [self login];
    }
    [self cancelTime];
}

- (void)cancelTime
{
    [self.overTimer invalidate];
    self.overTimer = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CompleteInformationViewController * completeVc = [[CompleteInformationViewController alloc]initWithNibName:@"CompleteInformationViewController" bundle:nil];
    [self.navigationController pushViewController:completeVc animated:YES];
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController * registerVC = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerVC animated:YES];
}
- (IBAction)fogetPaddwordAction:(id)sender {
    
    ForgetPAsswordViewController * forgetVC = [[ForgetPAsswordViewController alloc]initWithNibName:@"ForgetPAsswordViewController" bundle:nil];
    forgetVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:forgetVC animated:YES];
}

- (void)pushMyTabbarViewController
{
    MyTabBarController * myTabbrVc = [[MyTabBarController alloc]init];
//    [ShareApplicationDelegate window].rootViewController = myTabbrVc;
    [ShareApplicationDelegate window].rootViewController = [[UINavigationController alloc]initWithRootViewController:myTabbrVc];
}

- (void)getRongToken
{
    NSString * url = [NSString stringWithFormat:@"%@userinfo/getRongToken?token=%@", POST_URL, [UserInfo shareUserInfo].userToken];
    
    [[HDNetworking sharedHDNetworking] POSTwithToken:url parameters:nil progress:^(NSProgress * _Nullable progress) {
        ;
    } success:^(id  _Nonnull responseObject) {
        [hud hide:YES];
        NSLog(@"responseObject = %@", responseObject);
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 200) {
            [UserInfo shareUserInfo].rongToken = [responseObject objectForKey:@"RongToken"];
            [[RCIM sharedRCIM] connectWithToken:[UserInfo shareUserInfo].rongToken success:^(NSString *userId) {
                NSLog(@"连接融云成功");
                
                    [RCDHTTPTOOL refreshUserInfoByUserID:[NSString stringWithFormat:@"%@", responseObject[@"UserId"]]];
                
                // 同步好友列表
                NSString * url = [NSString stringWithFormat:@"%@userinfo/getFriendList?token=%@", POST_URL, [UserInfo shareUserInfo].userToken];
                [RCDDataSource syncFriendList:url complete:^(NSMutableArray *friends) {}];
                
                // 同步组群

                
            } error:^(RCConnectErrorCode status) {
                NSLog(@"连接融云失败");
            } tokenIncorrect:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getRongToken];
                });
                
            }];
            
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"Message"]] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert show];
            [alert performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        [hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"服务器连接失败,请重新操作" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [alert performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
        NSLog(@"%@", error);
    }];
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
