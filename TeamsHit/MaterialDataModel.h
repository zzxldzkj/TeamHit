//
//  MaterialDataModel.h
//  TeamsHit
//
//  Created by 仙林 on 16/7/27.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum:NSInteger {
    TextEditImageModel = 0,
    ProcessImageMOdel,
    expressionModel,
    QRCodeModel,
    GraffitiModel,
}ImageModel;

@interface MaterialDataModel : NSObject
@property (nonatomic, strong)UIImage * image;
@property (nonatomic, copy)NSString * title;
@property (nonatomic, assign)ImageModel imageModel;

@end