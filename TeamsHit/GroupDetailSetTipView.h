//
//  GroupDetailSetTipView.h
//  TeamsHit
//
//  Created by 仙林 on 16/9/7.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GroupDetailPickerBlock)(NSString * string);

@interface GroupDetailSetTipView : UIView<UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content isRule:(BOOL)isRule;
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content isRule:(BOOL)isRule ishaveQuit:(BOOL)ishaveQuit;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSArray *)content isPrint:(BOOL)isPrint;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title quit:(BOOL)quit;
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)content;

- (void)show;

- (void)dismiss;

- (void)getPickerData:(GroupDetailPickerBlock)block;

@property (strong, nonatomic) UIPickerView *customPicker;
@property (nonatomic, strong)NSArray * dataArr;
@property (nonatomic, copy)GroupDetailPickerBlock myblock;
@property (nonatomic, copy)NSString * comleteString;
@property (nonatomic, strong)UITextField * textFiled;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)UITableView * printTableView;
@property (nonatomic, assign)BOOL IsViewer;

@property (nonatomic, assign)BOOL ishaveQuit;

@end
