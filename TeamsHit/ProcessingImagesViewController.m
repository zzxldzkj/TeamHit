//
//  ProcessingImagesViewController.m
//  TeamsHit
//
//  Created by 仙林 on 16/7/19.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "ProcessingImagesViewController.h"

#define SELF_WIDTH self.view.frame.size.width
#define SELF_HEIGHT self.view.frame.size.height
#define TOOLBAR_HEIGHT 40
#import "ImageUtil.h"
#import "ProcessImageTypeView.h"
#import "TailorImageViewController.h"
#import "GraffitiViewController.h"
#import "UIImage+HDExtension.h"
#import "HDPicModle.h"
#import "UserInfo.h"

@interface ProcessingImagesViewController ()

{
    UIBarButtonItem * _imageType;
    UIBarButtonItem * _tailor;
    UIBarButtonItem * _print;
    UIBarButtonItem * _graffiti;
    UIBarButtonItem * _rotate;
    MBProgressHUD* hud ;
}

@property (nonatomic, copy)ProcessImage processImage;

@property (nonatomic, strong)UIScrollView * scrollView;
@property (nonatomic, strong)UIImageView * imageView;
@property (nonatomic, strong)UIToolbar * toolBar;

@property (nonatomic, strong)ProcessImageTypeView * processImageTypeView;
@property (nonatomic, strong)UIImage * defaultImage;
@property (nonatomic, strong)UIImage * finalImage;

@property (nonatomic, strong)UIImage * contraryImage;
@property (nonatomic, strong)UIImage * inkjetImage;

@property (nonatomic, copy)NSString * iconImageUrl;// 处理图片默认连接
@property (nonatomic, assign)int rotateNumber;//记录旋转方向

@property (nonatomic, assign)CGRect initailRect;// imageView初始rect

@end

@implementation ProcessingImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    TeamHitBarButtonItem * leftBarItem = [TeamHitBarButtonItem leftButtonWithImage:[UIImage imageNamed:@"img_back"] title:@""];
    self.title = @"图片处理";
    [leftBarItem addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    self.image = [UIImage imageNamed:@"face0.jpg"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.rotateNumber = 1;
    [self creatSubviews];
    
    hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud show:YES];
    
    self.image = [ImageUtil imageByScalingAndCroppingForSize:self.image];
    NSLog(@"image.size.width = %f, image.size.height = %f", _image.size.width, _image.size.height);
    [self dealImage];
    [self refreshUI];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

- (UIImage *)calculateImagesize:(UIImage *)image
{
    NSData *data;
    data = UIImageJPEGRepresentation(image, .1);
    image = [UIImage imageWithData:data];
    
    CGSize size = image.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.width * 0.3, size.height * 0.3));
    [image drawInRect:CGRectMake(0, 0, size.width * 0.3, size.height * 0.3)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)done
{
    if (self.processImage) {
        [ImageUtil erzhiBMPImage:self.finalImage];
//        [ImageUtil tailorborderImage:self.finalImage]
        _processImage([ImageUtil tailorborderImage:self.finalImage]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)creatSubviews
{
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.processImageTypeView];
    
    __weak ProcessingImagesViewController * processVC = self;
    [self.processImageTypeView getProcessImageType:^(int type) {
        [processVC processImageWithType:type];
    }];
    
}

- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        
//        _toolBar = [[UIToolbar alloc] init];
        _toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, SELF_HEIGHT - TOOLBAR_HEIGHT - 64, SELF_WIDTH, TOOLBAR_HEIGHT)];
        [self.toolBar setBackgroundImage:[UIImage new]forToolbarPosition:UIBarPositionAny                      barMetrics:UIBarMetricsDefault];
        [self.toolBar setShadowImage:[UIImage new]
                  forToolbarPosition:UIToolbarPositionAny];
        _toolBar.backgroundColor = UIColorFromRGB(0x12B7F5);
//        _toolBar.frame = CGRectMake(0, 164, SELF_WIDTH, TOOLBAR_HEIGHT);
        
        // 图片样式
        _imageType = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"ico_effects_checked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(changeType)];
        // 剪裁
        _tailor = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"imageTailor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(tailor)];
        // 打印
        _print = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"ico_print_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(print)];
        // 涂鸦
        _graffiti = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"ico_scrawl_02_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(graffiti)];
        // 旋转
        _rotate = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"ico_imagerotato_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(rotate)];
        
        UIBarButtonItem * space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        _toolBar.items = @[_imageType, space, _tailor, space, _print, space, _graffiti, space, _rotate];
        
    }
    return _toolBar;
}
- (ProcessImageTypeView *)processImageTypeView
{
    if (!_processImageTypeView) {
        _processImageTypeView = [[ProcessImageTypeView alloc]initWithFrame:CGRectMake(0, screenHeight - TOOLBAR_HEIGHT - 64 - 60, screenWidth, 60)];
    }
    return _processImageTypeView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - TOOLBAR_HEIGHT - 64)];
        _scrollView.backgroundColor = [UIColor blackColor];
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.hd_width, screenWidth)];
    }
    return _imageView;
}

#pragma mark - 从服务器获取处理图片
- (void)getDefaultImageFromServer
{
    hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"修改中...";
    [hud show:YES];
    
    HDPicModle * imageModel = [[HDPicModle alloc]init];
    imageModel.pic = self.image;
    imageModel.picName = [self imageName];
    imageModel.picFile = [[self getLibraryCachePath] stringByAppendingPathComponent:imageModel.picName];
    NSString * imageUrl = [NSString stringWithFormat:@"%@%@", POST_IMAGE_URL, @"1"];
    NSString * url = [imageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    __weak ProcessingImagesViewController * weakSelf = self;
    [[HDNetworking sharedHDNetworking] POST:url parameters:nil andPic:imageModel progress:^(NSProgress * _Nullable progress) {
        NSLog(@"progress = %lf", 1.0 * progress.completedUnitCount / progress.totalUnitCount);
    } success:^(id  _Nonnull responseObject) {
        NSLog(@"上传成功");
        NSLog(@"responseObject = %@", responseObject);
        
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"dic = %@", dic);
        weakSelf.iconImageUrl = [dic objectForKey:@"ImgPath"];
        [weakSelf completeInformation1];
    } failure:^(NSError * _Nonnull error) {
        [hud hide:YES];
        NSLog(@"error = %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"图片处理失败，请从新选择" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [alert performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (NSString *)imageName
{
    NSDateFormatter * myFormatter = [[NSDateFormatter alloc]init];
    [myFormatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString * strTime = [myFormatter stringFromDate:[NSDate date]];
    NSString * name = [NSString stringWithFormat:@"t%@%lld.png",  strTime, arc4random() % 9000000000 + 1000000000];
    return name;
}

- (NSString *)getLibraryCachePath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)completeInformation1
{
    
    NSDictionary * jsonDic = @{
                               @"IconUrl":self.iconImageUrl
                               };
    
    NSString * url = [NSString stringWithFormat:@"%@userinfo/completeInformation?token=%@", POST_URL, [UserInfo shareUserInfo].userToken];
    __weak ProcessingImagesViewController * weakSelf = self;
    [[HDNetworking sharedHDNetworking] POSTwithToken:url parameters:jsonDic progress:^(NSProgress * _Nullable progress) {
        ;
    } success:^(id  _Nonnull responseObject) {
        [hud hide:YES];
        NSLog(@"responseObject = %@", responseObject);
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 200) {
            
            NSString * imagebase64Str = [responseObject objectForKey:@"ImageData"];
            NSData * imageData = [[NSData alloc] initWithBase64EncodedString:imagebase64Str options:0];
            self.image = [UIImage imageWithData:imageData];
            [weakSelf dealImage];
            [weakSelf refreshUI];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"图片处理失败，请从新选择" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert show];
            [alert performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [hud hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"图片处理失败，请从新选择" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [alert performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)dealImage
{
    _imageView.image = [ImageUtil ditherImage:self.image];
    self.defaultImage = _imageView.image;
    self.finalImage = _imageView.image;
//    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil, nil);
    _imageView.hd_height = screenWidth *_imageView.image.size.height / _imageView.image.size.width;
    [hud hide:YES];
    
    [self performSelector:@selector(processImageinkblack) withObject:nil afterDelay:.4];
}

- (void)processImageinkblack
{
//    NSString* fileName = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.bmp", [UserInfo shareUserInfo].timeStr]];;
//    NSData * imageData = [NSData dataWithContentsOfFile:fileName];
//    NSLog(@"imageData = %@", [imageData base64EncodedStringWithOptions:0]);
//    https://pastebin.mozilla.org/8931101
//    
//    NSLog(@"创建新图片");
//    UIImage *erzhiImage = [UIImage imageWithContentsOfFile:fileName];
//    NSLog(@"新图片 = %@ ** 地址 + %@", erzhiImage, fileName);
//    _imageView.image = erzhiImage;
//    self.defaultImage = erzhiImage;
//    self.finalImage = erzhiImage;
    self.contraryImage = [ImageUtil imageBlackToTransparent:self.defaultImage];
    self.inkjetImage = [ImageUtil splashInk:self.image];
}

- (UIImage *)zoomImageScale:(UIImage *)image
{
    CGSize size = image.size;
    
    // 创建一个基于位图的图形上下文，使得其成为当前上下文
    UIGraphicsBeginImageContext(CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * size.height / size.width));
    [image drawInRect:CGRectMake(0, 0, SELF_WIDTH, SELF_WIDTH *size.height / size.width)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)refreshUI
{
    self.scrollView.contentSize = CGSizeMake(_scrollView.hd_width, _imageView.hd_height );
    
    self.initailRect = self.imageView.frame;
    
    if (_imageView.hd_height < _scrollView.hd_height) {
        _imageView.center = _scrollView.center;
    }
}

#pragma mark - toolBar点击事件
- (void)changeType
{
    NSData * data1 = UIImagePNGRepresentation(_imageType.image);
    NSData * data2 = UIImagePNGRepresentation([UIImage imageNamed:@"ico_effects_unchecked"]);
    if ([data1 isEqual:data2]) {
        [_imageType setImage:[[UIImage imageNamed:@"ico_effects_checked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.processImageTypeView.hidden = NO;
    }else
    {
        [_imageType setImage:[[UIImage imageNamed:@"ico_effects_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

        self.processImageTypeView.hidden = YES;
    }
}
- (void)tailor
{
    TailorImageViewController * tailorVC = [[TailorImageViewController alloc]initWithImage:self.imageView.image];
    __weak ProcessingImagesViewController * processVC = self;
    [tailorVC done:^(NSDictionary * imageDic) {
        [processVC tailorImage:imageDic];
    }];
    [self.navigationController pushViewController:tailorVC animated:NO];
}

- (void)print
{
    [[Print sharePrint] printImage:self.finalImage taskType:@0 toUserId:self.userId];
}
- (void)graffiti
{
    GraffitiViewController * graffitiVC = [[GraffitiViewController alloc]init];
    graffitiVC.sourceimage = self.finalImage;
    graffitiVC.userId = self.userId;
    __weak ProcessingImagesViewController * weakSelf = self;
    [graffitiVC graffitiImage:^(UIImage *image) {
        if (image) {
            weakSelf.imageView.image = image;
            weakSelf.finalImage = image;
            NSLog(@"获取到了");
        }
    }];
    [self.navigationController pushViewController:graffitiVC animated:YES];
}
- (void)rotate
{
    _rotateNumber++;
    if (_rotateNumber == 5) {
        _rotateNumber = 1;
    }
    [UIView animateWithDuration:.1 animations:^{

//        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI/2);
        
        self.imageView.image = [UIImage image:self.imageView.image rotation:UIImageOrientationRight];
        switch (_rotateNumber) {
            case 1:
            {
                self.imageView.frame = CGRectMake(0, 0, self.defaultImage.size.width, self.defaultImage.size.height);
                if (self.defaultImage.size.height > self.scrollView.hd_width) {
                    self.imageView.frame = self.initailRect;
                }
            }
                break;
            case 2:
            {
                self.imageView.frame = CGRectMake(0, 0, self.defaultImage.size.height, self.defaultImage.size.width);
                if (self.defaultImage.size.height > self.scrollView.hd_width) {
                    self.imageView.frame = CGRectMake(0, 0, _scrollView.hd_width, _scrollView.hd_width * self.imageView.hd_height / self.imageView.hd_width);
                }
            }
                break;
            case 3:
            {
                self.imageView.frame = CGRectMake(0, 0, self.defaultImage.size.width, self.defaultImage.size.height);
                if (self.defaultImage.size.height > self.scrollView.hd_width) {
                    self.imageView.frame = self.initailRect;
                }
            }
                break;
            case 4:
            {
                self.imageView.frame = CGRectMake(0, 0, self.defaultImage.size.height, self.defaultImage.size.width);
                if (self.defaultImage.size.height > self.scrollView.hd_width) {
                    self.imageView.frame = CGRectMake(0, 0, _scrollView.hd_width, _scrollView.hd_width * self.imageView.hd_height / self.imageView.hd_width);
                }
            }
                break;
                
            default:
                break;
        }
        self.imageView.center = self.scrollView.center;
    } completion:^(BOOL finished) {
        self.scrollView.contentSize = CGSizeMake(_scrollView.hd_width, _scrollView.hd_height);
        self.finalImage = [self imageWithUIView:self.imageView];
        NSLog(@"**** width = %f, height = %f", self.finalImage.size.width, self.finalImage.size.height);
    }];
}
-(UIImage *)imageWithUIView:(UIView *)view
{
    //UIGraphicsBeginImageContext(view.bounds.size);
//    UIGraphicsBeginImageContext(view.frame.size);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:ctx];
    
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tImage;
}
#pragma mark - ProcessImageType
- (void)processImageWithType:(int )type
{
    switch (type) {
        case 0:
        {
            _imageView.image = self.defaultImage;
            self.finalImage = self.defaultImage;
            
        }
            break;
        case 1:
            if (self.contraryImage) {
                self.imageView.image = self.contraryImage;
                self.finalImage = self.contraryImage;
            }else
            {
                self.imageView.image = [ImageUtil imageBlackToTransparent:self.defaultImage];
                self.finalImage = [ImageUtil imageBlackToTransparent:self.defaultImage];
            }
            break;
        case 2:
            NSLog(@"喷墨");
            if (self.inkjetImage) {
                self.imageView.image = self.inkjetImage;
                self.finalImage = self.inkjetImage;
            }else
            {
                self.imageView.image = [ImageUtil splashInk:self.defaultImage];
                self.finalImage = self.imageView.image;
                self.inkjetImage = self.imageView.image;
            }
            break;
        case 3:
             NSLog(@"描边");
            self.imageView.image = [ImageUtil memory:self.defaultImage];
            self.finalImage = [ImageUtil memory:self.defaultImage];
            break;
        case 4:
             NSLog(@"素描");
            
            break;
            
        default:
            break;
    }
}

#pragma mark - 图片剪切
- (void)tailorImage:(NSDictionary *)imageDic
{
    self.imageView.image =  [self zoomImageScale:[imageDic objectForKey:@"ImageArr"][0]];
    self.finalImage = [self zoomImageScale:[imageDic objectForKey:@"ImageArr"][0]];
    self.imageView.hd_height = SELF_WIDTH *self.imageView.image.size.height / self.imageView.image.size.width;
    if (self.imageView.hd_height < self.scrollView.hd_height) {
        self.imageView.center = self.scrollView.center;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.hd_width, self.imageView.hd_height );
    
    CGRect rect = CGRectFromString([imageDic objectForKey:@"Rect"]);
    CGRect imageViewRect = CGRectFromString([imageDic objectForKey:@"imageViewRecf"]);
    CGFloat scale = self.defaultImage.size.width / imageViewRect.size.width;
    self.defaultImage = [self cropImageWithScale:scale Rect:rect imageViewRect:imageViewRect];
}

- (UIImage *)cropImageWithScale:(CGFloat)scale
                           Rect:(CGRect)rect
                  imageViewRect:(CGRect)imageViewRect
{
    rect.origin.x = (rect.origin.x - imageViewRect.origin.x) * scale;
    rect.origin.y = (rect.origin.y - imageViewRect.origin.y) * scale;
    rect.size.width *= scale;
    rect.size.height *= scale;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self.defaultImage drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, self.defaultImage.size.width, self.defaultImage.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
    
}


- (void)didReceiveMemoryWarning {
    NSLog(@"内存警告");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processImage:(ProcessImage)processImage
{
    self.processImage = [processImage copy];
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
