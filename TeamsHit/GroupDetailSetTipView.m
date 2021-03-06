//
//  GroupDetailSetTipView.m
//  TeamsHit
//
//  Created by 仙林 on 16/9/7.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "GroupDetailSetTipView.h"
#import "AppDelegate.h"
#import "GameRuleModel.h"
#import "GameRulesTableViewCell.h"
#import "PrintDeviceTableViewCell.h"
#import "EquipmentModel.h"

#define GAME_RULECELL_IDENTIFIRE @"gamerulecell"
#define PRINTDEVICECELLID @"PrintDeviceTableViewCellid"

@interface GroupDetailSetTipView ()
{
    UIView * backWhiteView;
}
@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, strong)NSMutableArray * selectArr;

@property (nonatomic, assign)BOOL isQuit;
@property (nonatomic, assign)BOOL isPrint;

@end

@implementation GroupDetailSetTipView

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)selectArr
{
    if (!_selectArr) {
        _selectArr = [NSMutableArray array];
    }
    return _selectArr;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content
{
    if (self = [super initWithFrame:frame]) {
        [self prepareUIWith:title Content:content isRule:NO];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content isPrint:(BOOL)isPrint
{
    if (self = [super initWithFrame:frame]) {
        self.isPrint = isPrint;
        [self prepareUIWith:title Content:content isPrint:YES];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content isRule:(BOOL)isRule ishaveQuit:(BOOL)ishaveQuit
{
    if (self = [super initWithFrame:frame]) {
        self.ishaveQuit = YES;
        [self prepareUIWith:title Content:content isRule:isRule];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content isRule:(BOOL)isRule
{
    if (self = [super initWithFrame:frame]) {
        [self prepareUIWith:title Content:content isRule:isRule];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title quit:(BOOL)quit
{
    if (self = [super initWithFrame:frame]) {
        self.isQuit = quit;
        [self prepareUIWith:title Content:@[] isRule:NO];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)content
{
    if (self = [super initWithFrame:frame]) {
        [self prepareUIWith:title message:content];
    }
    return self;
}

- (void)prepareUIWith:(NSString *)title Content:(NSArray *)content isPrint:(BOOL)isPrint
{
    self.backgroundColor = [UIColor clearColor];
    self.dataArr = [NSArray arrayWithArray:content];
    UIView * backBlackView = [[UIView alloc]initWithFrame:self.bounds];
    backBlackView.backgroundColor = [UIColor colorWithWhite:.4 alpha:.5];
    [self addSubview:backBlackView];
    
    backWhiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 264, 152)];
    backWhiteView.layer.cornerRadius = 5;
    backWhiteView.layer.masksToBounds = YES;
    backWhiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backWhiteView];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, backWhiteView.hd_width, 44)];
    titleLabel.backgroundColor = UIColorFromRGB(0x12B7F5);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    titleLabel.textAlignment = 1;
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:titleLabel.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = titleLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    titleLabel.layer.mask = maskLayer;
    [backWhiteView addSubview:titleLabel];
    
    backWhiteView.hd_height = 213;
    
    self.printTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 57, backWhiteView.hd_width, 120) style:UITableViewStylePlain];
    self.printTableView.delegate = self;
    self.printTableView.dataSource = self;
    self.printTableView.backgroundColor = [UIColor whiteColor];
    self.printTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.printTableView registerNib:[UINib nibWithNibName:@"PrintDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:PRINTDEVICECELLID];
    
    
    UIButton * sureBT = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBT.frame = CGRectMake(backWhiteView.hd_width - 63, 184, 34, 16);
    [sureBT setTitle:@"确定" forState:UIControlStateNormal];
    sureBT.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureBT setTitleColor:UIColorFromRGB(0x12B7F5) forState:UIControlStateNormal];
    [backWhiteView addSubview:sureBT];
    
    [backWhiteView addSubview:self.printTableView];
    [sureBT addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [backBlackView addGestureRecognizer:tap];
    
    backWhiteView.center = self.center;
}


- (void)prepareUIWith:(NSString *)title Content:(NSArray *)content isRule:(BOOL)isRule
{
    self.backgroundColor = [UIColor clearColor];
    self.dataArr = [NSArray arrayWithArray:content];
    UIView * backBlackView = [[UIView alloc]initWithFrame:self.bounds];
    backBlackView.backgroundColor = [UIColor colorWithWhite:.4 alpha:.5];
    if (self.ishaveQuit) {
        backBlackView.backgroundColor = [UIColor colorWithWhite:.4 alpha:0];
    }
    [self addSubview:backBlackView];
    
    backWhiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 264, 152)];
    backWhiteView.layer.cornerRadius = 5;
    backWhiteView.layer.masksToBounds = YES;
    backWhiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backWhiteView];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, backWhiteView.hd_width, 44)];
    titleLabel.backgroundColor = UIColorFromRGB(0x12B7F5);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    titleLabel.textAlignment = 1;
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:titleLabel.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = titleLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    titleLabel.layer.mask = maskLayer;
    [backWhiteView addSubview:titleLabel];
    
    if (isRule) {
        backWhiteView.hd_height = 201;
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(22, 64, backWhiteView.hd_width - 52 , 120) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[GameRulesTableViewCell class] forCellReuseIdentifier:GAME_RULECELL_IDENTIFIRE];
        [backWhiteView addSubview:self.tableView];
        
        int height = 0;
        
        for (int i = 0;i < content.count;i++) {
            GameRuleModel * model = [[GameRuleModel alloc]init];
            model.number = i + 1;
            model.content = content[i];
            [model getcontentHeightWithWidth:self.tableView.hd_width - 20];
            [self.dataArray addObject:model];
            height += model.height + 10;
        }
        self.tableView.hd_height = height;
        height += 44 + 21 + 15;
        backWhiteView.hd_height = height;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [backBlackView addGestureRecognizer:tap];
        
    }
    else
    {
        if (self.isQuit) {
            backWhiteView.hd_height = 141;
            backBlackView.backgroundColor = [UIColor colorWithWhite:.3 alpha:.3];
            UITapGestureRecognizer * distap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
            [backBlackView addGestureRecognizer:distap];
            
            UIView * rulerView = [[UIView alloc]initWithFrame:CGRectMake(14, 60, backWhiteView.hd_width - 26, 20)];
            rulerView.backgroundColor = [UIColor whiteColor];
            [backWhiteView addSubview:rulerView];
            
            UIImageView * rulerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(14, 60, 17, 17)];
            rulerImageView.backgroundColor = [UIColor whiteColor];
            rulerImageView.image = [UIImage imageNamed:@"bragRuleImg"];
            rulerImageView.userInteractionEnabled = YES;
            [backWhiteView addSubview:rulerImageView];
            
            UILabel * rulerLabel = [[UILabel alloc]initWithFrame:CGRectMake(39, 61, 40, 15)];
            rulerLabel.text = @"规则";
            rulerLabel.textColor = UIColorFromRGB(0x12B7F5);
            rulerLabel.font = [UIFont systemFontOfSize:15];
            [backWhiteView addSubview:rulerLabel];
            
            UIImageView * goImageView = [[UIImageView alloc]initWithFrame:CGRectMake(backWhiteView.hd_width - 19, 60, 7, 15)];
            goImageView.image = [UIImage imageNamed:@"quitGameImg"];
            goImageView.userInteractionEnabled = YES;
            [backWhiteView addSubview:goImageView];
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookRuler)];
            [rulerView addGestureRecognizer:tap];
            
            UIButton * quitBT = [UIButton buttonWithType:UIButtonTypeCustom];
            quitBT.frame = CGRectMake(0, 92, 78, 25);
            quitBT.backgroundColor = UIColorFromRGB(0x12B7F5);
            quitBT.layer.cornerRadius = 8;
            quitBT.layer.masksToBounds = YES;
            [quitBT setTitle:@"退出游戏" forState:UIControlStateNormal];
            [quitBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            quitBT.titleLabel.font = [UIFont systemFontOfSize:15];
            [quitBT addTarget:self action:@selector(quitGameAction) forControlEvents:UIControlEventTouchUpInside];
            quitBT.hd_centerX = backWhiteView.hd_width / 2;
            [backWhiteView addSubview:quitBT];
            
        }else
        {
            
            if (content.count == 1) {
                UILabel * tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(27, 60, backWhiteView.hd_width - 54, 70)];
                tipLabel.font = [UIFont systemFontOfSize:15];
                tipLabel.textColor = UIColorFromRGB(0x12B7F5);
                tipLabel.text = content[0];
                tipLabel.numberOfLines = 0;
                CGSize tipSize = [tipLabel.text boundingRectWithSize:CGSizeMake(tipLabel.hd_width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
                tipLabel.hd_height = tipSize.height;
                [backWhiteView addSubview:tipLabel];
                
            }else if (content.count > 1)
            {
                self.customPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, backWhiteView.hd_width, 70)];
                self.customPicker.delegate = self;
                self.customPicker.dataSource = self;
                self.customPicker.backgroundColor = [UIColor clearColor];
                
                UIView * pickBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 65, _customPicker.hd_width, 28)];
                pickBackView.backgroundColor = UIColorFromRGB(0x12B7F5);
                pickBackView.alpha = .4;
                pickBackView.userInteractionEnabled = YES;
                [backWhiteView addSubview:pickBackView];
                [backWhiteView addSubview:self.customPicker];
            }else
            {
                self.textFiled = [[UITextField alloc]initWithFrame:CGRectMake(29, 66, backWhiteView.hd_width - 58, 34)];
                self.textFiled.layer.borderColor = UIColorFromRGB(0x12B7F5).CGColor;
                self.textFiled.layer.borderWidth = 1;
                self.textFiled.layer.cornerRadius = 5;
                self.textFiled.layer.masksToBounds = YES;
                self.textFiled.borderStyle = UITextBorderStyleNone;
                self.textFiled.delegate = self;
                self.textFiled.returnKeyType = UIReturnKeyDone;
                [backWhiteView addSubview:self.textFiled];
                
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
                [backBlackView addGestureRecognizer:tap];
            }
            
            UIButton * cancleBT = [UIButton buttonWithType:UIButtonTypeCustom];
            cancleBT.frame = CGRectMake(backWhiteView.hd_width - 114, 118, 34, 16);
            [cancleBT setTitle:@"取消" forState:UIControlStateNormal];
            cancleBT.titleLabel.font = [UIFont systemFontOfSize:12];
            [cancleBT setTitleColor:UIColorFromRGB(0xBABABA) forState:UIControlStateNormal];
            [backWhiteView addSubview:cancleBT];
            [cancleBT addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton * sureBT = [UIButton buttonWithType:UIButtonTypeCustom];
            sureBT.frame = CGRectMake(backWhiteView.hd_width - 63, 118, 34, 16);
            [sureBT setTitle:@"确定" forState:UIControlStateNormal];
            sureBT.titleLabel.font = [UIFont systemFontOfSize:12];
            [sureBT setTitleColor:UIColorFromRGB(0x12B7F5) forState:UIControlStateNormal];
            [backWhiteView addSubview:sureBT];
            [sureBT addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
            if (content.count == 0) {
                cancleBT.hidden = YES;
                sureBT.hd_centerX = backWhiteView.hd_centerX;
            }
        }
    }
    
    backWhiteView.center = self.center;
    
}

- (void)prepareUIWith:(NSString *)title message:(NSString *)content
{
    self.backgroundColor = [UIColor clearColor];
    UIView * backBlackView = [[UIView alloc]initWithFrame:self.bounds];
    backBlackView.backgroundColor = [UIColor colorWithWhite:.4 alpha:.5];
    [self addSubview:backBlackView];
    
    backWhiteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 264, 152)];
    backWhiteView.layer.cornerRadius = 5;
    backWhiteView.layer.masksToBounds = YES;
    backWhiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backWhiteView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [backBlackView addGestureRecognizer:tap];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, backWhiteView.hd_width, 44)];
    titleLabel.backgroundColor = UIColorFromRGB(0x12B7F5);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    titleLabel.textAlignment = 1;
    UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:titleLabel.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer * maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = titleLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    titleLabel.layer.mask = maskLayer;
    [backWhiteView addSubview:titleLabel];
    
    
    
    UILabel * tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(27, 60, backWhiteView.hd_width - 54, 70)];
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.textColor = UIColorFromRGB(0x12B7F5);
    tipLabel.text = content;
    tipLabel.numberOfLines = 0;
    CGSize tipSize = [tipLabel.text boundingRectWithSize:CGSizeMake(tipLabel.hd_width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    tipLabel.hd_height = tipSize.height;
    [backWhiteView addSubview:tipLabel];
    
    UIButton * sureBT = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBT.frame = CGRectMake(backWhiteView.hd_width - 63, 118, 34, 16);
    [sureBT setTitle:@"确定" forState:UIControlStateNormal];
    sureBT.titleLabel.font = [UIFont systemFontOfSize:12];
    [sureBT setTitleColor:UIColorFromRGB(0x12B7F5) forState:UIControlStateNormal];
    [backWhiteView addSubview:sureBT];
    [sureBT addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    
    backWhiteView.center = self.center;
}

#pragma mark - 查看规则
- (void)lookRuler
{
    if (self.myblock) {
        self.myblock(@"lookRuler");
    }
}

- (void)quitGameAction
{
    if (self.IsViewer) {
        if (self.myblock) {
            self.myblock(@"quit");
            return;
        }
    }
    
    UIView * quitTipView = [[UIView alloc]initWithFrame:CGRectMake((self.hd_width - 275) / 2, backWhiteView.hd_y + 50, 275 , 138)];
    quitTipView.backgroundColor = [UIColor whiteColor];
    quitTipView.layer.cornerRadius = 3;
    quitTipView.layer.masksToBounds = YES;
    [self addSubview:quitTipView];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 16, 85, 15)];
    titleLabel.text = @"三思而后行";
    titleLabel.textColor = MAIN_COLOR;
    titleLabel.font = [UIFont systemFontOfSize:15];
    [quitTipView addSubview:titleLabel];
    
    UILabel * contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 50, 196, 40)];
    contentLabel.textColor = MAIN_COLOR;
    contentLabel.text = @"游戏中退出，会损失大量的碰碰币和积分。";
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.numberOfLines = 0;
    [quitTipView addSubview:contentLabel];
    
    UIButton * sureBT = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBT.frame = CGRectMake(quitTipView.hd_width - 133, 99, 45, 22);
    sureBT.layer.cornerRadius = 3;
    sureBT.layer.masksToBounds = YES;
    sureBT.backgroundColor = MAIN_COLOR;
    [sureBT setTitle:@"确定" forState:UIControlStateNormal];
    [sureBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBT addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [quitTipView addSubview:sureBT];
    
    UIButton * cancleBT = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBT.frame = CGRectMake(quitTipView.hd_width - 73, 99, 45, 22);
    cancleBT.layer.cornerRadius = 3;
    cancleBT.layer.masksToBounds = YES;
    cancleBT.backgroundColor = MAIN_COLOR;
    [cancleBT setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancleBT addTarget:self action:@selector(cancleAction:) forControlEvents:UIControlEventTouchUpInside];
    [quitTipView addSubview:cancleBT];
    
    
}

- (void)sureAction:(UIButton *)bt
{
    if (self.myblock) {
        self.myblock(@"quit");
    }
}

- (void)cancleAction:(UIButton *)bt
{
    [self dismiss];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.comleteString = self.dataArr[row];
}

#pragma mark - UIPickerViewDatasource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel * pickerLabel = (UILabel *)view;
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0, 0, self.hd_width, 23);
        pickerLabel = [[UILabel alloc]initWithFrame:frame];
        pickerLabel.textAlignment = 1;
        pickerLabel.backgroundColor = [UIColor whiteColor];
        [pickerLabel setFont:[UIFont systemFontOfSize:15.0f]];
    }
    pickerLabel.text = [self.dataArr objectAtIndex:row];
    pickerLabel.backgroundColor = [UIColor clearColor];
    
    return pickerLabel;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataArr.count;
}

- (void)show
{
    AppDelegate * delegate = [UIApplication sharedApplication].delegate;
    
    [delegate.window addSubview:self];
}

- (void)dismiss
{
    self.alpha = 1;
    [UIView animateWithDuration:.4 animations:^{
        self.alpha = 0;
        
        for (EquipmentModel * model in [Print sharePrint].deviceArr) {
            model.isSelect = NO;
        }
        
    } completion:^(BOOL finished) {
        [self removeAllSubviews];
        [self removeFromSuperview];
    }];
}

- (void)completeAction
{
    if (self.textFiled) {
        if (self.textFiled.text.length != 0) {
            self.comleteString = self.textFiled.text;
            if (self.myblock) {
                _myblock(self.comleteString);
                [self dismiss];
            }
        }else
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"房间名称不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else
    {
        if (self.isPrint) {
            NSString * taskNumber = @"";
            for (EquipmentModel * model in self.selectArr) {
                taskNumber = [taskNumber stringByAppendingFormat:@"%@,", model.uuid];
            }
            if (taskNumber.length <= 0) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有选择打印机" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [alert show];
                [alert performSelector:@selector(dismiss) withObject:nil afterDelay:1];
                return;
            }
            taskNumber = [taskNumber substringToIndex:taskNumber.length - 1];
            self.comleteString = taskNumber;
            [self dismiss];
        }
        
        if (self.myblock) {
            _myblock(self.comleteString);
            [self dismiss];
        }
    }
    
}

- (void)getPickerData:(GroupDetailPickerBlock)block
{
    self.myblock = [block copy];
}

#pragma mark - tableviewdelegate datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.printTableView]) {
        return self.dataArr.count;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.printTableView]) {
        PrintDeviceTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:PRINTDEVICECELLID forIndexPath:indexPath];
        EquipmentModel * model = self.dataArr[indexPath.row];
        
        if (model.deviceName.length == 0) {
            cell.deviceNameLabel.text = model.uuid;
        }else
        {
            cell.deviceNameLabel.text = model.deviceName;
        }
        
        if (!model.isSelect) {
            cell.typeImage.image = [UIImage imageNamed:@"printOrderUnselect.png"];
        }else
        {
            cell.typeImage.image = [UIImage imageNamed:@"printOrderSelect.png"];
        }
        
        return cell;
    }else
    {
        GameRulesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:GAME_RULECELL_IDENTIFIRE forIndexPath:indexPath];
        [cell creatCellWithFrame:tableView.bounds];
        GameRuleModel * model = self.dataArray[indexPath.row];
        cell.numberlabel.text = [NSString stringWithFormat:@"%d", model.number];
        cell.contentLabel.text = model.content;
        return cell;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.printTableView]) {
        return 31;
    }else
    {
        GameRuleModel * model = self.dataArray[indexPath.row];
        if (model.height < 25) {
            return 25;
        }else
        {
            return model.height + 10;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.printTableView]) {
        EquipmentModel * model = self.dataArr[indexPath.row];
        if (model.isSelect) {
            model.isSelect = NO;
            [self.selectArr removeObject:model];
        }else
        {
            model.isSelect = YES;
            [self.selectArr addObject:model];
        }
        [self.printTableView reloadData];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
